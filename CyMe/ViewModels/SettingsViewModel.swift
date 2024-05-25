//
//  File.swift
//  CyMe
//
//  Created by Marinja Principe on 22.05.24.
//

import Foundation

class SettingsViewModel: ObservableObject {
    @Published var settings = SettingsModel(
        // measuring and reporting settings
        enableHealthKit: false,
        measuringWithWatch: true,
        enableSleepQualityMeasuring: true,
        enableSleepQualitySelfReporting: false,
        enableSleepLengthMeasuring: true,
        enableSleepLengthSelfReporting: false,
        enableMenstrualCycleLengthMeasuring: true,
        enableMenstrualCycleLengthReporting: false,
        enableHeartRateMeasuring: false,
        enableHeartRateReporting: true,
        
        // reminder settings
        selfReportWithWatch: true,
        startPeriodReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
        selfReportReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
        summaryReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),

        // theme settings
        selectedTheme: ThemeModel(name: "Deep blue", backgroundColor: .white, primaryColor: lightBlue, accentColor: .blue),
        enableWidget: true
    )
    
    private var settingsDatabaseService: SettingsDatabaseService
        
    init() {
        settingsDatabaseService = SettingsDatabaseService()
        loadSettings()
    }
    
    func saveSettings() {
        settingsDatabaseService.saveSettings(settings: settings)
    }
    
    func loadSettings() {
        self.settings = settingsDatabaseService.getSettings()
    }
    
}

