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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            if DatabaseService.shared.userDatabaseService.isUserPresent() {
                ContentView()
            } else {
                OnboardingView()
                //ContentView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Failed to request notification permission: \(error)")
            }
        }
        return true
    }

    // This method will be called when the app is in the foreground and a notification is received
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound]) // Show the notification as a banner with sound
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.content.categoryIdentifier == "selfReportCategory" {
            NotificationCenter.default.post(name: Notification.Name("NotificationTapped"), object: nil)
        }
        completionHandler()
    }
}
