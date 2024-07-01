//
//  SettingsView.swift
//  CyMe
//
//  Created by Marinja Principe on 08.05.24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @StateObject var connector = WatchConnector()
    
    @State private var currentPageIndex = 0
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    
    var body: some View {
        VStack {
            if currentPageIndex == 0 {
                ProfileView(nextPage: goToNextPage, settingsViewModel: settingsViewModel, userViewModel: profileViewModel )
            } else if currentPageIndex == 1 {
                PersonalizationView(nextPage: goToNextPage, settingsViewModel: settingsViewModel)
            } else if currentPageIndex == 2 {
                PersonalizationSelfReportView(nextPage: goToNextPage, settingsViewModel: settingsViewModel)
            } else if currentPageIndex == 3 {
                PersonalizationThemeView(nextPage: goToNextPage, settingsViewModel: settingsViewModel)
            } else {
                ContentView()
            }
        }
    }
    
    func goToNextPage() {
        currentPageIndex += 1
    }

    /*var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Period Tracking")) {
                    Toggle("Enable Period Tracking", isOn: $periodTrackingEnabled)
                }
                Section(header: Text("Headache Tracking")) {
                    Toggle("Enable Period Tracking", isOn: $headacheTrackingEnabled)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                // Dismiss settings view
                isPresented = false
                submitToWatch()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }*/
    
    func submitToWatch() {
        //TODO
    }


}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true))
    }
}
