//
//  CyMeApp.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//

import SwiftUI

@main
struct CyMeApp: App {
    @State private var isOnboardingComplete = false

    var body: some Scene {
        WindowGroup {
            if isOnboardingComplete {
                ContentView()
            } else {
                OnboardingView()
                    .onAppear {
                        // Check if the database file exists
                        if let _ = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("CyMe.sqlite") {
                            // Database file exists, check if the user exists
                            if let userName = DatabaseService.shared.userDatabaseService.getUserName() {
                                print("User name: \(userName)")
                                // User exists, set isOnboardingComplete to true to switch to ContentView
                                isOnboardingComplete = true
                            } else {
                                print("No user name found")
                                // User doesn't exist, onboarding is required
                            }
                        }
                    }
            }
        }
    }
}



