//
//  CyMeApp.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//

import SwiftUI

@main
struct CyMeApp: App {
    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .onAppear {
                    // Check if the user table exists
                    let userName = DatabaseService.shared.getUserName()
                    if let userName = userName {
                        print("User name: \(userName)")
                    } else {
                        print("No user name found")
                    }
                }
        }
    }
}

