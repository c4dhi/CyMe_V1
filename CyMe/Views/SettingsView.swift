//
//  SettingsView.swift
//  CyMe
//
//  Created by Marinja Principe on 08.05.24.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Binding var isPresented: Bool
    
    @State private var currentPageIndex = 1
    
    init(settingsViewModel: SettingsViewModel, isPresented: Binding<Bool>) {
        self.settingsViewModel = settingsViewModel
        self._isPresented = isPresented
    }
    
    var body: some View {
        VStack {
            if currentPageIndex == 1 {
                PersonalizationView(nextPage: goToNextPage, settingsViewModel: settingsViewModel)
            } else if currentPageIndex == 2 {
                PersonalizationSelfReportView(nextPage: goToNextPage, settingsViewModel: settingsViewModel)
            } else if currentPageIndex == 3 {
                PersonalizationThemeView(nextPage: goToNextPage, settingsViewModel: settingsViewModel)
            }
        }
        .onAppear {
            Logger.shared.log("Settings view is shown")
        }
        .onChange(of: currentPageIndex) { newValue in
            if newValue >= 4 {
                isPresented = false
            }
        }
    }
    
    func goToNextPage() {
        currentPageIndex += 1
    }

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let connector = WatchConnector()
        let settingsViewModel = SettingsViewModel(connector: connector)
        SettingsView(settingsViewModel: settingsViewModel, isPresented: .constant(true))
    }
}
