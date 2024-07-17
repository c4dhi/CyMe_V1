//
//  File.swift
//  CyMe
//
//  Created by Marinja Principe on 22.05.24.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var settings: SettingsModel
        
    private var themeManager = ThemeManager()
    private var settingsDatabaseService: SettingsDatabaseService
    private var connector: WatchConnector
    
    init(connector: WatchConnector) {
        self.connector = connector
        self.settingsDatabaseService = SettingsDatabaseService()
        self.settings = settingsDatabaseService.getSettings() ?? settingsDatabaseService.getDefaultSettings()
    }
    
    func saveSettings() {
        themeManager.saveThemeToUserDefaults(newTheme: settings.selectedTheme)
        settingsDatabaseService.saveSettings(settings: settings)
        connector.sendSettings(settings: settings)
        setNotifications(isEnabled: settings.selfReportReminder.isEnabled, startDate: settings.selfReportReminder.startDate, times: settings.selfReportReminder.times, frequency: settings.selfReportReminder.frequency)
        
    }
    
    func setNotifications(isEnabled: Bool, startDate: Date, times: [Date], frequency: String) {
        removeAllScheduledNotifications()
        guard isEnabled else { return }
        
        for time in times {
            if let combinedDate = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: time), minute: Calendar.current.component(.minute, from: time), second: 0, of: startDate) {
                scheduleNotification(at: combinedDate, frequency: frequency)
                Logger.shared.log("Notification set at: \(combinedDate)")
            }
        }
    }
    
    
}


