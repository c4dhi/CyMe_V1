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
                                            title: "Menstrual data",
                                            enableDataSync: true,
                                            enableSelfReportingCyMe: true,
                                            dataLocation: .sync,
                                            question: "Did you have your period today?",
                                            questionType: .yesNo
                                        ),
                                        HealthDataSettingsModel(
                                            title: "Sleep quality",
                                            enableDataSync: false,
                                            enableSelfReportingCyMe: false,
                                            dataLocation: .onlyCyMe,
                                            question: "Rate your sleep quality last night",
                                            questionType: .emoticonRating
                                        ),
                                        HealthDataSettingsModel(
                                            title: "Sleep length",
                                            enableDataSync: false,
                                            enableSelfReportingCyMe: false,
                                            dataLocation: .sync,
                                            question: "How many hours did you sleep?",
                                            questionType: .amountOfhour
                                        ),
                                        HealthDataSettingsModel(
                                            title: "Headache",
                                            enableDataSync: false,
                                            enableSelfReportingCyMe: false,
                                            dataLocation: .sync,
                                            question: "Did you experience a headache today?",
                                            questionType: .frequency
                                        ),
                                        HealthDataSettingsModel(
                                            title: "Stress",
                                            enableDataSync: false,
                                            enableSelfReportingCyMe: false,
                                            dataLocation: .onlyCyMe,
                                            question: "Rate your stress level today",
                                            questionType: .intensity
                                        ),
                                        HealthDataSettingsModel(
                                            title: "Abdominal cramps",
                                            enableDataSync: false,
                                            enableSelfReportingCyMe: false,
                                            dataLocation: .sync,
                                            question: "Did you experience abdominal cramps today?",
                                            questionType: .frequency
                                        ),
                                        HealthDataSettingsModel(
                                            title: "Lower back pain",
                                            enableDataSync: false,
                                            enableSelfReportingCyMe: false,
                                            dataLocation: .sync,
                                            question: "Did you experience lower back pain today?",
                                            questionType: .intensity
                                        ),
                                        HealthDataSettingsModel(
                                            title: "Pelvic pain",
                                            enableDataSync: false,
                                            enableSelfReportingCyMe: false,
                                            dataLocation: .sync,
                                            question: "Did you experience pelvic pain today?",
                                            questionType: .intensity
                                        ),
                                        HealthDataSettingsModel(
                                            title: "Acne",
                                            enableDataSync: false,
                                            enableSelfReportingCyMe: false,
                                            dataLocation: .sync,
                                            question: "Did you have acne today?",
                                            questionType: .yesNo
                                        ),
                                        HealthDataSettingsModel(
                                            title: "Appetite changes",
                                            enableDataSync: false,
                                            enableSelfReportingCyMe: false,
                                            dataLocation: .sync,
                                            question: "Did you experience changes in appetite today?",
                                            questionType: .intensity
                                        ),
                                        HealthDataSettingsModel(
                                            title: "Tightness or pain in the chest",
                                            enableDataSync: false,
                                            enableSelfReportingCyMe: false,
                                            dataLocation: .sync,
                                            question: "Did you experience tightness or pain in the chest today?",
                                            questionType: .yesNo
                                        ),
                                        HealthDataSettingsModel(
                                            title: "Step data",
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

