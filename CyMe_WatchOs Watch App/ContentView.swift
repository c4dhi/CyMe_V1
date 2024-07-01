//
//  ContentView.swift
//  CyMe_WatchOs Watch App
//
//  Created by Marinja Principe on 17.04.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        VStack {
            if !settingsViewModel.settings.healthDataSettings.isEmpty {
                SelfReportWatchView(settingsViewModel: settingsViewModel)
            } else {
                VStack {
                    Button(action: {
                        settingsViewModel.fetchSettings()
                    }) {
                        Text("Fetch Settings")
                    }
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
