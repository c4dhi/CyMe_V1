//
//  OnboardingView.swift
//  CyMe
//
//  Created by Marinja Principe on 13.05.24.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var connector: WatchConnector
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @State private var currentPageIndex: Int = 0
    @StateObject private var profileViewModel = ProfileViewModel()
    
    var body: some View {
        VStack {
            if currentPageIndex == 0 {
                WelcomeView(nextPage: goToNextPage)
            } else if currentPageIndex == 1 {
                ProfileView(nextPage: goToNextPage, settingsViewModel: settingsViewModel, userViewModel: profileViewModel )
            } else if currentPageIndex == 2 {
                PersonalizationView(nextPage: goToNextPage, settingsViewModel: settingsViewModel)
            } else if currentPageIndex == 3 {
                PersonalizationSelfReportView(nextPage: goToNextPage, settingsViewModel: settingsViewModel)
            } else if currentPageIndex == 4 {
                PersonalizationThemeView(nextPage: goToNextPage, settingsViewModel: settingsViewModel)
            } else {
                ContentView()
            }
        }
    }
    
    func goToNextPage() {
        currentPageIndex += 1
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
