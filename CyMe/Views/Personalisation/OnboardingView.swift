//
//  OnboardingView.swift
//  CyMe
//
//  Created by Marinja Principe on 13.05.24.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPageIndex = 0
    
    var body: some View {
        VStack {
            if currentPageIndex == 0 {
                WelcomeView(nextPage: goToNextPage)
            } else if currentPageIndex == 1 {
                ProfileView(nextPage: goToNextPage)
            } else if currentPageIndex == 2 {
                PersonalizationView(nextPage: goToNextPage)
            } else if currentPageIndex == 3 {
                PersonalizationSelfReportView(nextPage: goToNextPage)
           } else if currentPageIndex == 4 {
               PersonalizationThemeView(nextPage: goToNextPage)
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
