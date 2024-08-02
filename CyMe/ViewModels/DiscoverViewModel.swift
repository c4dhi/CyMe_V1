//
//  DiscoverViewModel.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.

import Foundation
import SigmaSwiftStatistics
import HealthKit



class DiscoverViewModel: ObservableObject {
    @Published var symptoms: [SymptomModel] = []
    
    var reportingDatabaseService: ReportingDatabaseService

    var relevantDataClass : RelevantData
    var menstruationRanges : MenstruationRanges
    
    var combinedDataDict : [cycleTimeOptions : CombinedDataModel] = [:]
    var availableCycles : Int = 0
    var selfReports: [ReviewReportModel] = []
     
    var symptomsDict : [cycleTimeOptions : SymptomModel] = [:]
    

    init() {
        reportingDatabaseService =  ReportingDatabaseService()
        
        relevantDataClass = RelevantData()
        menstruationRanges = MenstruationRanges()
        
        Task{
            await updateSymptoms()
        }
    }
    
    
    func updateSymptoms (currentCycle : Bool = true) async {
        
        
        let fillCombinedDataModel = await fillCombinedDataModel(menstruationRanges: menstruationRanges, relevantData: relevantDataClass)
            
        combinedDataDict = fillCombinedDataModel.combinedDataDict
        selfReports = fillCombinedDataModel.selfReports
        availableCycles = fillCombinedDataModel.availableCycles
        
        let buildSelfreportedSymptomsClass = BuildAHSelfReportedSymptoms(relevantDataList: relevantDataClass.relevantForDisplay, combinedDataDict : combinedDataDict, menstruationRanges : menstruationRanges, availableCycles : availableCycles)
        let buildCollectedSymptomsClass = BuildCollectedSymptoms(relevantDataList: relevantDataClass.relevantForDisplay, combinedDataDict : combinedDataDict, menstruationRanges : menstruationRanges, availableCycles : availableCycles)
        let buildCMSelfreportedSymptomsClass = BuildCMSelfReportedSymptoms(relevantDataList: relevantDataClass.relevantForDisplay, combinedDataDict : combinedDataDict, menstruationRanges : menstruationRanges, availableCycles : availableCycles)
        
        let symptomDictSelfReported = buildSelfreportedSymptomsClass.buildSelfReportedSymptoms()
        let symptomDictCollected = buildCollectedSymptomsClass.buildCollectedSymptoms()
        let symptomDictCMSelfReported = buildCMSelfreportedSymptomsClass.buildSelfReportedSymptoms()
        
        let symptomDict : [cycleTimeOptions : [SymptomModel]] = [.current : (symptomDictCMSelfReported[.current]! + symptomDictSelfReported[.current]! + symptomDictCollected[.current]!), .last : (symptomDictCMSelfReported[.last]! + symptomDictSelfReported[.last]! + symptomDictCollected[.last]!) , .secondToLast : (symptomDictCMSelfReported[.secondToLast]! + symptomDictSelfReported[.secondToLast]! + symptomDictCollected[.secondToLast]! )]

    
        DispatchQueue.main.async {
            if currentCycle{
                self.symptoms = symptomDict[.current]!
            }
            else { // Display the last full cycle
                self.symptoms = symptomDict[.last]!
            }
        }
    }
}
