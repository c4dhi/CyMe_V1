//
//  QuestionViewModel.swift
//  CyMe
//
//  Created by Marinja Principe on 02.06.24.
//

import Foundation
import SwiftUI

class SelfReportViewModel: ObservableObject {
    @Published var questions: [HealthDataSettingsModel] = []
    @Published var answers: [String: String] = [:] // To store answers, using the title as key

    private var settingsViewModel: SettingsViewModel
    private var reportingDatabaseService: ReportingDatabaseService

    init(settingsViewModel: SettingsViewModel) {
            self.settingsViewModel = settingsViewModel
            self.reportingDatabaseService = ReportingDatabaseService()
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
    
    func saveReport() -> Bool {
        let selfReportModel = createSelfReportModel()
        let success = reportingDatabaseService.saveReporting(report: selfReportModel)
        if success {
            print("Report saved successfully!")
            return true
        } else {
            print("Failed to save the report.")
            return false
        }
    }
    
    private func createSelfReportModel() -> SelfReportModel {
        let symptoms = questions.compactMap { question in
            answers[question.title].map { answer in
                SymptomSelfReportModel(healthDataTitle: question.title, questionType: question.questionType ?? .painEmoticonRating, reportedValue: answer)
            }
        }

        let startTime = Date()
        let endTime = Date()
        let isSelfReport = true
        let selfReportMedium = selfReportMediumType.iOSApp

        return SelfReportModel(
            id: nil,
            startTime: startTime,
            endTime: endTime,
            isSelfReport: isSelfReport,
            selfReportMedium: selfReportMedium,
            reports: symptoms
        )
    }
}
