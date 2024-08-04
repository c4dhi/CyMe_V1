import SwiftUI
import UniformTypeIdentifiers
import UIKit
import Zip



class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    var onDocumentPicked: ((URL) -> Void)?

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        onDocumentPicked?(url)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        Logger.shared.log("Document picker was cancelled")
    }
}

func zipFiles(sourceURLs: [URL], destinationURL: URL) {
    do {
        try Zip.zipFiles(paths: sourceURLs, zipFilePath: destinationURL, password: nil, progress: nil)
        Logger.shared.log("Zipped successfully to \(destinationURL.path)")
    } catch {
        Logger.shared.log("Failed to zip files: \(error.localizedDescription)")
    }
}


struct SettingsNavigationView: View {
    @Binding var isPresented: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showProfileSheet = false
    @State private var showOnboardingSheet = false
    @State private var databaseURL: URL?
    @State private var documentPickerDelegate = DocumentPickerDelegate()
    
    init(settingsViewModel: SettingsViewModel, isPresented: Binding<Bool>) {
        self.settingsViewModel = settingsViewModel
        self._isPresented = isPresented
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button("Profile") {
                showProfileSheet = true
            }
            .foregroundColor(themeManager.theme.accentColor.toColor())
            .sheet(isPresented: $showProfileSheet) {
                ProfileViewWrapper(isPresented: $showProfileSheet, settingsViewModel: settingsViewModel )
            }

            Button("CyMe settings") {
                showOnboardingSheet = true
            }
            .foregroundColor(themeManager.theme.accentColor.toColor())
            .sheet(isPresented: $showOnboardingSheet) {
                OnboardingViewWrapper(isPresented: $isPresented, settingsViewModel: settingsViewModel)
            }

            Button("Download CyMe data") {
                Logger.shared.log("User is downloading the user data")
                downloadDatabaseFile()
            }
            .foregroundColor(themeManager.theme.accentColor.toColor())
        }
        .padding()
        .background(.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }

    func downloadDatabaseFile() {
        if DatabaseService.shared.databaseFileExists() {
            databaseURL = DatabaseService.shared.databaseURL()
            Logger.shared.log("Database file found at \(databaseURL!.path)")
            anonymizeAndPresentDocumentPicker()
        } else {
            Logger.shared.log("Database file not found")
        }
    }

    func anonymizeAndPresentDocumentPicker() {
        guard let originalDatabaseURL = databaseURL else { return }

        let tempDatabaseURL = FileManager.default.temporaryDirectory.appendingPathComponent("CyMe_database.sqlite")

        do {
            // Remove the existing file if it exists
            if FileManager.default.fileExists(atPath: tempDatabaseURL.path) {
                try FileManager.default.removeItem(at: tempDatabaseURL)
            }

            try FileManager.default.copyItem(at: originalDatabaseURL, to: tempDatabaseURL)
            Logger.shared.log("Temporary database created at \(tempDatabaseURL.path)")
            
            UserDatabaseService().anonymizeUserTable(at: tempDatabaseURL)
            Logger.shared.log("User table anonymized in temporary database")

            // Zip the database and log file
            let logFileURL = Logger.shared.logFileURL // Update this to your log file path
            let zipDestinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("CyMe.zip")
            zipFiles(sourceURLs: [tempDatabaseURL, logFileURL], destinationURL: zipDestinationURL)
            
            presentDocumentPicker(for: zipDestinationURL)
        } catch {
            Logger.shared.log("Error copying database: \(error.localizedDescription)")
        }
    }


    func presentDocumentPicker(for databaseURL: URL) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [databaseURL])
        documentPicker.delegate = documentPickerDelegate
        documentPicker.modalPresentationStyle = .fullScreen

        documentPickerDelegate.onDocumentPicked = { url in
            do {
                try FileManager.default.copyItem(at: databaseURL, to: url)
                Logger.shared.log("Files copied to [\(url.path)]")
                presentFilePreviewController(with: url)
            } catch {
                Logger.shared.log("Copy failed: \(error.localizedDescription)")
            }
        }

        UIApplication.shared.windows.first?.rootViewController?.present(documentPicker, animated: true)
    }

    func presentFilePreviewController(with url: URL) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let filePreviewController = storyboard.instantiateViewController(withIdentifier: FilePreviewController.controllerIdentifier) as? FilePreviewController else { return }
        filePreviewController.url = url
        filePreviewController.modalPresentationStyle = .fullScreen
        UIApplication.shared.windows.first?.rootViewController?.present(filePreviewController, animated: true)
    }
}


struct ProfileViewWrapper: View {
    @Binding var isPresented: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            ProfileView(nextPage: { isPresented = false }, settingsViewModel: settingsViewModel, userViewModel: ProfileViewModel())
                .navigationBarItems(leading: Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(themeManager.theme.accentColor.toColor())
                })
        }
    }
}

struct OnboardingViewWrapper: View {
    @Binding var isPresented: Bool
    @ObservedObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            SettingsView(settingsViewModel: settingsViewModel, isPresented: $isPresented)
                .navigationBarTitle("Settings", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(themeManager.theme.accentColor.toColor())
                })
        }
    }
}

struct SettingsNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        let connector = WatchConnector()
        let settingsViewModel = SettingsViewModel(connector: connector)
        SettingsNavigationView(settingsViewModel: settingsViewModel, isPresented: .constant(true))
    }
}
