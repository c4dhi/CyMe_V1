//
//  SettingsModel.swift
//  CyMe
//
//  Created by Marinja Principe on 22.05.24.
//

import Foundation

struct SettingsModel {
    // measuring and reporting settings
    var enableHealthKit: Bool
    var HealthDataSettings: [HealthDataSettingsModel]
    
    // reminder settings
    var selfReportWithWatch: Bool
    var enableWidget: Bool
    var startPeriodReminder: ReminderModel
    var selfReportReminder: ReminderModel
    var summaryReminder: ReminderModel
    
    // theme settings
    var selectedTheme: ThemeModel
    
    
}

