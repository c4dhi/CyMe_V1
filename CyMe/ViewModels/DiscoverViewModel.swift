//
//  DiscoverViewModel.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.

// Used in the discover and visualization page 
import Foundation
import SigmaSwiftStatistics
import HealthKit



class DiscoverViewModel: ObservableObject {
    @Published var symptoms: [SymptomModel] = []
    
    var reportingDatabaseService: ReportingDatabaseService

    //var relevantDataClass : RelevantData
    var menstruationRanges : MenstruationRanges
    
    var combinedDataDict : [cycleTimeOptions : CombinedDataModel] = [:]
    var availableCycles : Int = 0
    var selfReports: [ReviewReportModel] = []
     
    var symptomsDict : [cycleTimeOptions : [SymptomModel]] = [:]
 
    

    init() {
        reportingDatabaseService =  ReportingDatabaseService()
        menstruationRanges = MenstruationRanges()
    }
    
    func updateChoice (currentCycle : Bool = true) async {
        DispatchQueue.main.async {
            if currentCycle{
                self.symptoms = self.symptomsDict[.current]!
            }
            else { // Display the last full cycle
                self.symptoms = self.symptomsDict[.last]!
            }
        }
    }
    
    
    func updateSymptoms (currentCycle : Bool = true, settingsViewModel : SettingsViewModel) async {
        
        let relevantDataClass = RelevantData(settingsViewModel: settingsViewModel)
        
        let fillCombinedDataModel = await fillCombinedDataModel(menstruationRanges: menstruationRanges, relevantData: relevantDataClass)
            
        combinedDataDict = fillCombinedDataModel.combinedDataDict
        selfReports = fillCombinedDataModel.selfReports
        availableCycles = fillCombinedDataModel.availableCycles
    
        let buildSymptomsClass = BuildSymptoms(relevantDataList: relevantDataClass.relevantForDisplay, combinedDataDict : combinedDataDict, menstruationRanges : menstruationRanges, availableCycles : availableCycles)
        symptomsDict = buildSymptomsClass.buildSymptoms()
    
        DispatchQueue.main.async {
            if currentCycle{
                self.symptoms = self.symptomsDict[.current]!
            }
            else { // Display the last full cycle
                self.symptoms = self.symptomsDict[.last]!
            }
        }
    }
}
