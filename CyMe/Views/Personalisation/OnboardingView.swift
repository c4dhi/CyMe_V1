//
//  OnboardingView.swift
//  CyMe
//
//  Created by Marinja Principe on 13.05.24.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPageIndex: Int
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    
    init(startPageIndex: Int = 0) {
        self._currentPageIndex = State(initialValue: startPageIndex)
    }
    
    var body: some View {
        VStack {
            if currentPageIndex == 0 {
                WelcomeView(nextPage: goToNextPage, settingsViewModel: settingsViewModel)
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
