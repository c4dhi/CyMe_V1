import SwiftUI
import UniformTypeIdentifiers
import UIKit

class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    var onDocumentPicked: ((URL) -> Void)?

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        onDocumentPicked?(url)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled")
    }
}

struct SettingsNavigationView: View {
    @Binding var isPresented: Bool
    @State private var showProfileSheet = false
    @State private var showOnboardingSheet = false
    @State private var databaseURL: URL?
    @State private var documentPickerDelegate = DocumentPickerDelegate()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button("Profile") {
                showProfileSheet = true
            }
            .foregroundColor(.blue)
            .sheet(isPresented: $showProfileSheet) {
                ProfileViewWrapper(isPresented: $showProfileSheet)
            }

            Button("CyMe Settings") {
                showOnboardingSheet = true
            }
            .foregroundColor(.blue)
            .sheet(isPresented: $showOnboardingSheet) {
                OnboardingViewWrapper(isPresented: $showOnboardingSheet)
            }

            Button("Download CyMe data") {
                downloadDatabaseFile()
            }
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }

    func downloadDatabaseFile() {
        if DatabaseService.shared.databaseFileExists() {
            databaseURL = DatabaseService.shared.databaseURL()
            anonymizeAndPresentDocumentPicker()
        } else {
            print("Database file not found")
        }
    }

    func anonymizeAndPresentDocumentPicker() {
        guard let originalDatabaseURL = databaseURL else { return }

        let tempDatabaseURL = FileManager.default.temporaryDirectory.appendingPathComponent("CyMe_database.sqlite")

        do {
            try FileManager.default.copyItem(at: originalDatabaseURL, to: tempDatabaseURL)
            UserDatabaseService().anonymizeUserTable(at: tempDatabaseURL)
            presentDocumentPicker(for: tempDatabaseURL)
        } catch {
            print("Error copying database: \(error.localizedDescription)")
        }
    }

    func presentDocumentPicker(for databaseURL: URL) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [databaseURL])
        documentPicker.delegate = documentPickerDelegate
        documentPicker.modalPresentationStyle = .fullScreen

        // Handle document picker actions
        documentPickerDelegate.onDocumentPicked = { url in
            do {
                try FileManager.default.copyItem(at: databaseURL, to: url)
                print("File copied to [\(url.path)]")
                presentFilePreviewController(with: url)
            } catch {
                print("Copy failed: \(error.localizedDescription)")
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

    var body: some View {
        NavigationView {
            ProfileView(nextPage: { isPresented = false }, settingsViewModel: SettingsViewModel(), userViewModel: ProfileViewModel())
                .navigationBarTitle("Profile", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                })
        }
    }
}

struct OnboardingViewWrapper: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            OnboardingView(startPageIndex: 2)
                .navigationBarTitle("Settings", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                })
        }
    }
}

struct SettingsNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsNavigationView(isPresented: .constant(true))
    }
}
