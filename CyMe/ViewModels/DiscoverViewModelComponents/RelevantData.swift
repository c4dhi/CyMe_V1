//
//  RelevantData.swift
//  CyMe
//
//  Created by Deborah on 04.07.2024.
//

import Foundation

class RelevantData {
    var relevantForDisplay : [availableHealthMetrics] = []
    var relevantForAppleHealthFetch : [availableHealthMetrics] = []
    var relevantForCyMeFetch : [availableHealthMetrics] = []
    
    var settingsDatabaseService = SettingsDatabaseService()
    
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
    
    
    
    func getRelevantDataLists() async {
    
        relevantForDisplay  = []
        relevantForAppleHealthFetch  = []
        relevantForCyMeFetch  = []
        
        DispatchQueue.main.async {
            let healthDataSettings = self.settingsDatabaseService.getSettings()?.healthDataSettings
            
            for setting in healthDataSettings! {
                if(setting.enableDataSync){
                    self.relevantForAppleHealthFetch.append(self.dBtoAvailableHealthMetrics[setting.name]!)
                }
                if(setting.enableSelfReportingCyMe){
                    self.relevantForCyMeFetch.append(self.dBtoAvailableHealthMetrics[setting.name]!)
                }
                if(setting.enableSelfReportingCyMe) || (setting.enableDataSync){
                    self.relevantForDisplay.append(self.dBtoAvailableHealthMetrics[setting.name]!)
                }
            }
        }
    }
    
    
}
