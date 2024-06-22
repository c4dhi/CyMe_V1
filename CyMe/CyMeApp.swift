//
//  CyMeApp.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//

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
            if DatabaseService.shared.userDatabaseService.isUserPresent() {
                ContentView()
            } else {
                //OnboardingView()
                ContentView()
            }
        }
    }
}

