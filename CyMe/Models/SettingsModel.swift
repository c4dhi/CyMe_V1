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
    var measuringWithWatch: Bool
    var enableSleepQualityMeasuring: Bool
    var enableSleepQualitySelfReporting: Bool
    var enableSleepLengthMeasuring: Bool
    var enableSleepLengthSelfReporting: Bool
    var enableMenstrualCycleLengthMeasuring: Bool
    var enableMenstrualCycleLengthReporting: Bool
    var enableHeartRateMeasuring: Bool
    var enableHeartRateReporting: Bool
    
    // reminder settings
    var selfReportWithWatch: Bool
    var startPeriodReminder: ReminderModel
    var selfReportReminder: ReminderModel
    var summaryReminder: ReminderModel
    
    // theme settings
    var selectedTheme: ThemeModel
    var enableWidget: Bool
    
}

