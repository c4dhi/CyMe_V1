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
    
    private var connector: iOSConnector
    
    init() {
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
                enableSelfReportingCyMe: false,
                dataLocation: .onlyCyMe,
                question: "Rate your sleep quality last night",
                questionType: .emoticonRating
            ),
            HealthDataSettingsModel(
                name: "sleepLenght",
                label: "Sleep length",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .sync,
                question: "How many hours did you sleep?",
                questionType: .amountOfhour
            ),],
            selfReportWithWatch: false,
            enableWidget: false,
            startPeriodReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
            selfReportReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
            summaryReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
            selectedTheme: ThemeModel(name: "", backgroundColor: .clear, primaryColor: .clear, accentColor: .clear)
        )
        
        self.connector = iOSConnector()
    }
    
    public func fetchSettings() {
        connector.requestSettingsFromiOS()
    }
}


