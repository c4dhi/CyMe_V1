//
//  SelfReportViewModel.swift
//  CyMe_WatchOs Watch App
//
//  Created by Marinja Principe on 03.06.24.
//

import Foundation
import SwiftUI
import SharedModels

class SelfReportViewModel: ObservableObject {
    @Published var questions: [HealthDataSettingsModel] = []
    @Published var answers: [String: String] = [:] // To store answers, using the title as key
    
    private var settingsViewModel: SettingsViewModel
    
    init(settingsViewModel: SettingsViewModel) {
            self.settingsViewModel = settingsViewModel
            loadQuestions()
        }
        
        private func loadQuestions() {
            questions = settingsViewModel.settings.healthDataSettings.filter {
                ($0.dataLocation == .sync || $0.dataLocation == .onlyCyMe) && $0.question != nil && $0.questionType != nil
            }
            
            for question in questions {
                answers[question.title] = nil
            }
        }
}
