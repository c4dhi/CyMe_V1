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
    @ObservedObject var connector: iOSConnector
    
    private var settingsViewModel: SettingsViewModel

    init(settingsViewModel: SettingsViewModel, connector: iOSConnector) {
        self.settingsViewModel = settingsViewModel
        self.connector = connector
        loadQuestions()
    }
        
    private func loadQuestions() {
        questions = settingsViewModel.settings.healthDataSettings.filter {
            ($0.dataLocation == .sync || $0.dataLocation == .onlyCyMe) && $0.question != nil && $0.questionType != nil
        }
    }
    
}

