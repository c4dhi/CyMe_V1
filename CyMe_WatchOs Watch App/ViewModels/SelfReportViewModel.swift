//
//  SelfReportViewModel.swift
//  CyMe_WatchOs Watch App
//
//  Created by Marinja Principe on 03.06.24.
//

import Foundation
import SwiftUI

class SelfReportViewModel: ObservableObject {
    @Published var questions: [HealthDataSettingsModel] = []
    
    private var settingsViewModel: SettingsViewModel
    private var iOSConnector: iOSConnector

    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
        self.iOSConnector = CyMe_WatchOs_Watch_App.iOSConnector()
        loadQuestions()
    }
        
    private func loadQuestions() {
        questions = settingsViewModel.settings.healthDataSettings.filter {
            ($0.dataLocation == .sync || $0.dataLocation == .onlyCyMe) && $0.question != nil && $0.questionType != nil
        }
    }
    
    func saveReport(selfReports: [SymptomSelfReportModel], startTime: Date) -> Bool {
            let selfReportModel = createSelfReportModel(selfReports: selfReports, startTime: startTime)
            iOSConnector.sendSelfReportDataToiOS(selfReport: selfReportModel)
            return true
        }
    
    private func createSelfReportModel(selfReports: [SymptomSelfReportModel], startTime: Date) -> SelfReportModel {
        let endTime = Date()
        let isCyMeSelfReport = true
        let selfReportMedium = selfReportMediumType.watchApp

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

