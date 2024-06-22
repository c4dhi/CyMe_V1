//
//  SettingsViewModel.swift
//  CyMe_WatchOs Watch App
//
//  Created by Marinja Principe on 03.06.24.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var settings: SettingsModel
    
        
    init() {
        self.settings = SettingsModel(enableHealthKit: false,
                  healthDataSettings:[
                    HealthDataSettingsModel(
                        name: "Menstrual data",
                        label: "Menstrual data",
                        enableDataSync: true,
                        enableSelfReportingCyMe: true,
                        dataLocation: .sync,
                        question: "Did you have your period today?",
                        questionType: .menstruationEmoticonRating
                    ),
                    HealthDataSettingsModel(
                        name: "Sleep quality",
                        label: "Sleep quality",
                        enableDataSync: false,
                        enableSelfReportingCyMe: false,
                        dataLocation: .onlyCyMe,
                        question: "Rate your sleep quality last night",
                        questionType: .emoticonRating
                    ),
                    HealthDataSettingsModel(
                        name: "Sleep length",
                        label: "Sleep length",
                        enableDataSync: false,
                        enableSelfReportingCyMe: false,
                        dataLocation: .sync,
                        question: "How many hours did you sleep?",
                        questionType: .amountOfhour
                    ),
                    HealthDataSettingsModel(
                        name: "Headache",
                        label: "Headache",
                        enableDataSync: false,
                        enableSelfReportingCyMe: false,
                        dataLocation: .sync,
                        question: "Did you experience a headache today?",
                        questionType: .painEmoticonRating
                    ),
                    HealthDataSettingsModel(
                        name: "Stress",
                        label: "Stress",
                        enableDataSync: false,
                        enableSelfReportingCyMe: false,
                        dataLocation: .onlyCyMe,
                        question: "Rate your stress level today",
                        questionType: .emoticonRating
                    ),
                    HealthDataSettingsModel(
                        name: "Abdominal cramps",
                        label: "Abdominal cramps",
                        enableDataSync: false,
                        enableSelfReportingCyMe: false,
                        dataLocation: .sync,
                        question: "Did you experience abdominal cramps today?",
                        questionType: .painEmoticonRating
                    ),
                    HealthDataSettingsModel(
                        name: "Lower back pain",
                        label: "Lower back pain",
                        enableDataSync: false,
                        enableSelfReportingCyMe: false,
                        dataLocation: .sync,
                        question: "Did you experience lower back pain today?",
                        questionType: .painEmoticonRating
                    ),
                    HealthDataSettingsModel(
                        name: "Pelvic pain",
                        label: "Pelvic pain",
                        enableDataSync: false,
                        enableSelfReportingCyMe: false,
                        dataLocation: .sync,
                        question: "Did you experience pelvic pain today?",
                        questionType: .painEmoticonRating
                    ),
                    HealthDataSettingsModel(
                        name: "Acne",
                        label: "Acne",
                        enableDataSync: false,
                        enableSelfReportingCyMe: false,
                        dataLocation: .sync,
                        question: "Did you have acne today?",
                        questionType: .painEmoticonRating
                    ),
                    HealthDataSettingsModel(
                        name: "Appetite changes",
                        label: "Appetite changes",
                        enableDataSync: false,
                        enableSelfReportingCyMe: false,
                        dataLocation: .sync,
                        question: "Did you experience changes in appetite today?",
                        questionType: .painEmoticonRating
                    ),
                    HealthDataSettingsModel(
                        name: "Tightness or pain in the chest",
                        label: "Tightness or pain in the chest",
                        enableDataSync: false,
                        enableSelfReportingCyMe: false,
                        dataLocation: .sync,
                        question: "Did you experience tightness or pain in the chest today?",
                        questionType: .painEmoticonRating
                    ),
                    HealthDataSettingsModel(
                        name: "Step data",
                        label: "Step data",
                        enableDataSync: false,
                        enableSelfReportingCyMe: false,
                        dataLocation: .onlyAppleHealth,
                        question: nil,
                        questionType: nil
                    )
                ],
                  selfReportWithWatch: true,
                  enableWidget: true,
                  startPeriodReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
                  selfReportReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
                  summaryReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
                  selectedTheme: ThemeModel(name: "Deep blue", backgroundColor: .white, primaryColor: .blue, accentColor: .blue))
    }
    
    func saveSettings() {
       // TODO save in IOS Connector
    }
    
}

