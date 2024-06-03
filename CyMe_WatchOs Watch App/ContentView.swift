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
        SelfReportView(settingsViewModel: settingsViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
