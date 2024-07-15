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

    private var settingsViewModel: SettingsViewModel
    private var reportingDatabaseService: ReportingDatabaseService

    init(settingsViewModel: SettingsViewModel) {
            self.settingsViewModel = settingsViewModel
            self.reportingDatabaseService = ReportingDatabaseService()
            loadQuestions()
    }
        
    private func loadQuestions() {
        questions = settingsViewModel.settings.healthDataSettings.filter {
            ($0.dataLocation == .sync || $0.dataLocation == .onlyCyMe) && $0.question != nil && $0.questionType != nil && $0.enableSelfReportingCyMe == true
        }
    }
    
    func saveReport(selfReports: [SymptomSelfReportModel], startTime: Date) -> Bool {
        let selfReportModel = createSelfReportModel(selfReports: selfReports, startTime: startTime)
        let success = reportingDatabaseService.saveReporting(report: selfReportModel)
        if success {
            Logger.shared.log("Report saved successfully!")
            return true
        } else {
            Logger.shared.log("Failed to save the report.")
            return false
        }
    }
    
    private func createSelfReportModel(selfReports: [SymptomSelfReportModel], startTime: Date) -> SelfReportModel {
        let endTime = Date()
        let isCyMeSelfReport = true
        let selfReportMedium = selfReportMediumType.iOSApp

        return SelfReportModel(
            id: nil,
            startTime: startTime,
            endTime: endTime,
            isCyMeSelfReport: isCyMeSelfReport,
            selfReportMedium: selfReportMedium,
            reports: selfReports
        )
    }
}
