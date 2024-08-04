//
//  RelevantData.swift
//  CyMe
//
//  Created by Deborah on 04.07.2024.
//

import Foundation

class RelevantData {
    var relevantForDisplay : [availableHealthMetrics] = []
    var relevantForAppleHealth : [availableHealthMetrics] = []
    var relevantForCyMeSelfReport : [availableHealthMetrics] = []
    
    var settingsViewModel : SettingsViewModel
    
    let dBtoAvailableHealthMetrics : [String : availableHealthMetrics] =
                                    ["menstruationDate" : .menstrualBleeding,
                                    "sleepQuality" : .sleepQuality,
                                    "sleepLenght" : .sleepLength,
                                    "headache" : .headache,
                                    "stress" : .stress,
                                    "abdominalCramps" : .abdominalCramps,
                                    "lowerBackPain" : .lowerBackPain,
                                    "pelvicPain" : .pelvicPain,
                                    "acne" : .acne,
                                    "appetiteChanges" : .appetiteChange,
                                    "chestPain" : .chestTightnessOrPain,
                                    "stepData" : .stepCount,
                                    "mood" : .mood,
                                    "exerciseTime" : .exerciseTime,
                                    "menstruationStart" : .menstrualStart]

    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
    }
    
    func getRelevantDataLists(){
        relevantForDisplay  = []
        relevantForAppleHealth  = []
        relevantForCyMeSelfReport = []
        
        var healthDataSettings = settingsViewModel.settings.healthDataSettings
        
        for setting in healthDataSettings {
            if(setting.enableDataSync){
                self.relevantForAppleHealth.append(self.dBtoAvailableHealthMetrics[setting.name]!)
            }
            if(setting.enableSelfReportingCyMe){
                self.relevantForCyMeSelfReport.append(self.dBtoAvailableHealthMetrics[setting.name]!)
            }
            if(setting.enableSelfReportingCyMe) || (setting.enableDataSync){
                self.relevantForDisplay.append(self.dBtoAvailableHealthMetrics[setting.name]!)
            }
        }
    }
}
