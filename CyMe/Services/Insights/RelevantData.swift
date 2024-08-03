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
    
    var settingsDatabaseService : SettingsDatabaseService? = nil
    var settingsViewModel : SettingsViewModel?
    
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

    init(settingsViewModel: SettingsViewModel? = nil) {
        self.settingsViewModel = settingsViewModel
    }
    
    func getRelevantDataLists() async {
        relevantForDisplay  = []
        relevantForAppleHealth  = []
        relevantForCyMeSelfReport = []
        
        var healthDataSettings : [HealthDataSettingsModel]
        
        if settingsViewModel == nil{
            settingsDatabaseService = SettingsDatabaseService()
            healthDataSettings = await getSettingLists()
        }
        else {
            healthDataSettings = settingsViewModel!.settings.healthDataSettings
        }
       
        
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
    
    func getSettingLists() async -> [HealthDataSettingsModel]  {
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let healthDataSettings = self.settingsDatabaseService!.getSettings()?.healthDataSettings
                continuation.resume(returning: healthDataSettings!)
            }
        }
    }
}
