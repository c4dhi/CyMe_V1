//
//  SelfReportViewModel.swift
//  CyMe_WatchOs Watch App
//
//  Created by Marinja Principe on 03.06.24.
//

import Foundation
import SwiftUI

class SelfReportViewModel: ObservableObject {
    @ObservedObject var connector: iOSConnector
    @Published var settings: SettingsModel

    init( connector: iOSConnector) {
        self.connector = connector
        
        self.settings = SettingsModel(
            enableHealthKit: false,
            healthDataSettings: [HealthDataSettingsModel(
                name: "menstruationDate",
                label: "Menstruation date",
                enableDataSync: true,
                enableSelfReportingCyMe: true,
                dataLocation: .sync,
                question: "Did you have your period today?",
                questionType: .menstruationEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "sleepQuality",
                label: "Sleep quality",
                enableDataSync: false,
                enableSelfReportingCyMe: true,
                dataLocation: .onlyCyMe,
                question: "Rate your sleep quality last night",
                questionType: .emoticonRating
            ),
            HealthDataSettingsModel(
                name: "headache",
                label: "Headache",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .sync,
                question: "Did you experience a headache today?",
                questionType: .painEmoticonRating
            ),],
            selfReportWithWatch: false,
            enableWidget: false,
            startPeriodReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
            selfReportReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
            summaryReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
            selectedTheme: ThemeModel(name: "", backgroundColor: .clear, primaryColor: .clear, accentColor: .clear)
        )
        loadQuestions()
    }
        
    private func loadQuestions() {
        connector.requestSettingsFromiOS { [weak self] healthSettings in
            if let healthSettings = healthSettings {
                DispatchQueue.main.async {
                    self?.settings.healthDataSettings = healthSettings
                }
            }
        }
    }
    
}

