//
//  NotificationService.swift
//  CyMe
//
//  Created by Marinja Principe on 01.07.24.
//

import Foundation
import UserNotifications

func scheduleNotification(at date: Date, frequency: String) {
    let content = UNMutableNotificationContent()
    content.title = "Time to Self-Report"
    content.body = "Please take a moment to self-report your activities."
    content.sound = UNNotificationSound.default
    content.categoryIdentifier = "selfReportCategory"
    
    var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
    var repeats = false

    switch frequency {
    case "Each day":
        dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        repeats = true
    case "Each second day":
        dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        // Custom implementation needed as UNCalendarNotificationTrigger doesn't directly support every other day
    case "Once a week":
        dateComponents = Calendar.current.dateComponents([.weekday, .hour, .minute], from: date)
        repeats = true
    case "Each hour":
        dateComponents = Calendar.current.dateComponents([.minute], from: date)
        repeats = true
    case "Multiple times per day":
        dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        repeats = false
        // Multiple notifications needed, not handled by a single trigger
    default:
        break
    }

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
    
    let uuidString = UUID().uuidString
    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
    
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.add(request) { (error) in
        if let error = error {
            Logger.shared.log("Error adding notification: \(error)")
        } else {
            Logger.shared.log("Notification scheduled successfully for \(date) with frequency \(frequency)")
        }
    }
}

func removeAllScheduledNotifications() {
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.removeAllPendingNotificationRequests()
    notificationCenter.removeAllDeliveredNotifications()
}
