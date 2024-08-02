//
//  DiscoveryService.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.

import HealthKit
import Foundation
import Combine

class HealthKitService {
    
    
    // General Objects
    let healthStore = HKHealthStore()
    
    // Create a sort descriptor for a chronological sort
    let sortDescriptorChronological = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
    
    
    let relevantDataObject = RelevantData()
    
    
    
    private let typesToRead: Set<HKSampleType> = [
        // Must - Read Access - CategoryType
        HKObjectType.categoryType(forIdentifier: .menstrualFlow)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.categoryType(forIdentifier: .headache)!,
        HKObjectType.categoryType(forIdentifier: .abdominalCramps)!,
        HKObjectType.categoryType(forIdentifier: .lowerBackPain)!,
        HKObjectType.categoryType(forIdentifier: .pelvicPain)!,
        HKObjectType.categoryType(forIdentifier: .acne)!,
        HKObjectType.categoryType(forIdentifier: .chestTightnessOrPain)!,
        HKObjectType.categoryType(forIdentifier: .appetiteChanges)!,
        // Must -  Read Access - QuantityType
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        
        // Should - Read Access - QuantityType
        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
        //HKObjectType.quantityType(forIdentifier: .appleSleepingWristTemperature)!
        ]
    
    
    private let typesToWrite: Set<HKSampleType> = [
        // Must - Write Access - CategoryType
        HKObjectType.categoryType(forIdentifier: .menstrualFlow)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.categoryType(forIdentifier: .headache)!,
        HKObjectType.categoryType(forIdentifier: .abdominalCramps)!,
        HKObjectType.categoryType(forIdentifier: .lowerBackPain)!,
        HKObjectType.categoryType(forIdentifier: .pelvicPain)!,
        HKObjectType.categoryType(forIdentifier: .acne)!,
        HKObjectType.categoryType(forIdentifier: .chestTightnessOrPain)!,
        HKObjectType.categoryType(forIdentifier: .appetiteChanges)!]
    
    // Variables for development
    private let enablePrintStatement = true
    
    func requestAuthorization() {
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { (success, error) in
            if success {
  
            } else {
                // Authorization failed, handle error
                if let error = error {
                    print("Authorization failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateSyncList() async {
        await relevantDataObject.getRelevantDataLists()
    }
   
    func writeSamplesToAppleHealth(selfReports: [SymptomSelfReportModel], startTime : Date){
        Task{
            let syncList = relevantDataObject.relevantForAppleHealth
            let symptomCyMeLabelToAppleLabel = ["No": 1, "Mild": 2, "Moderate": 3 , "Severe": 4]
            let appetiteChangeCyMeToAppleLabel = ["No": 1, "Less": 2, "More": 3]
            let menstruationCyMeToAppleLabel = ["No": 5, "Mild": 2, "Moderate": 3 , "Severe": 4]
            
            
            for selfReport in selfReports {
            
                if selfReport.healthDataName == "menstruationDate"{
                    if selfReport.reportedValue != nil{
                        if syncList.contains(.menstrualBleeding){
                            let dataType =  HKObjectType.categoryType(forIdentifier: .menstrualFlow)!
                            let value =  menstruationCyMeToAppleLabel[selfReport.reportedValue!]!
                            var periodStart : Bool = false
                            
                            for report in selfReports{
                                if report.healthDataName == "menstruationStart"{
                                    if report.reportedValue ?? "false" == "true"{
                                        periodStart = true
                                    }
                                    else{
                                        periodStart = false
                                    }
                                }
                            }
                            
                            let metadata: [String: Any] = [
                                HKMetadataKeyMenstrualCycleStart: periodStart
                            ]
                            
                            let menstrualFlowSample = HKCategorySample(
                                type: dataType,
                                value: value,
                                start: startTime,
                                end: startTime,
                                metadata: metadata
                            )
                            
                            healthStore.save(menstrualFlowSample) { (success, error) in
                                if let error = error {
                                    print("Error saving menstrual flow sample: \(error.localizedDescription)")
                                } else {
                                    print("Successfully saved menstrual flow sample")
                                }
                            }
                        }
                    }
                }
                if selfReport.healthDataName == "headache"{
                    if selfReport.reportedValue != nil{
                        if syncList.contains(.headache){
                            let dataNameIdentifier : HKCategoryTypeIdentifier = .headache
                            let value =  symptomCyMeLabelToAppleLabel[selfReport.reportedValue!]!
                            writeSelfreportedSample(dataName: dataNameIdentifier, value: value, startTime: startTime)
                        }
                    }
                }
                
                if selfReport.healthDataName == "abdominalCramps"{
                    if selfReport.reportedValue != nil{
                        if syncList.contains(.abdominalCramps){
                            let dataNameIdentifier : HKCategoryTypeIdentifier = .abdominalCramps
                            let value =  symptomCyMeLabelToAppleLabel[selfReport.reportedValue!]!
                            writeSelfreportedSample(dataName: dataNameIdentifier, value: value, startTime: startTime)
                        }
                    }
                }
                
                if selfReport.healthDataName == "lowerBackPain"{
                    if selfReport.reportedValue != nil{
                        if syncList.contains(.lowerBackPain){
                            let dataNameIdentifier : HKCategoryTypeIdentifier = .lowerBackPain
                            let value =  symptomCyMeLabelToAppleLabel[selfReport.reportedValue!]!
                            writeSelfreportedSample(dataName: dataNameIdentifier, value: value, startTime: startTime)
                        }
                    }
                }
                
                if selfReport.healthDataName == "pelvicPain"{
                    if selfReport.reportedValue != nil{
                        if syncList.contains(.pelvicPain){
                            let dataNameIdentifier : HKCategoryTypeIdentifier = .pelvicPain
                            let value =  symptomCyMeLabelToAppleLabel[selfReport.reportedValue!]!
                            writeSelfreportedSample(dataName: dataNameIdentifier, value: value, startTime: startTime)
                        }
                    }
                }
                
                if selfReport.healthDataName == "acne"{
                    if selfReport.reportedValue != nil{
                        if syncList.contains(.acne){
                            let dataNameIdentifier : HKCategoryTypeIdentifier = .acne
                            let value =  symptomCyMeLabelToAppleLabel[selfReport.reportedValue!]!
                            writeSelfreportedSample(dataName: dataNameIdentifier, value: value, startTime: startTime)
                        }
                    }
                }
                
                if selfReport.healthDataName == "appetiteChanges"{
                    if selfReport.reportedValue != nil{
                        if syncList.contains(.appetiteChange){
                            let dataNameIdentifier : HKCategoryTypeIdentifier = .appetiteChanges
                            let value =  appetiteChangeCyMeToAppleLabel[selfReport.reportedValue!]!
                            writeSelfreportedSample(dataName: dataNameIdentifier, value: value, startTime: startTime)
                        }
                    }
                }
                
                if selfReport.healthDataName == "chestPain"{
                    if selfReport.reportedValue != nil{
                        if syncList.contains(.chestTightnessOrPain){
                            let dataNameIdentifier : HKCategoryTypeIdentifier = .chestTightnessOrPain
                            let value =  symptomCyMeLabelToAppleLabel[selfReport.reportedValue!]!
                            writeSelfreportedSample(dataName: dataNameIdentifier, value: value, startTime: startTime)
                        }
                    }
                }
            }
        }
    }
    
    
    
    func writeSelfreportedSample(dataName: HKCategoryTypeIdentifier, value : Int, startTime : Date){
        guard let dataType = HKObjectType.categoryType(forIdentifier: dataName) else {
            print("Data type of name (\(dataName) not available")
            return
        }
        let selfreportedSample = HKCategorySample(type: dataType, value: value, start: startTime, end: startTime)
        
        
        healthStore.save(selfreportedSample) { (success, error) in
            if success {
                if self.enablePrintStatement{ print("Selfreported sample saved successfully") }
            } else {
                 print("Error saving selfreported data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    
    func fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier, startDate: Date, endDate: Date) async throws -> [AppleHealthSefReportModel]{
        guard let dataType = HKObjectType.categoryType(forIdentifier: dataName) else {
            print("Data type of name (\(dataName) not available")
            return []
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])
            let query = HKSampleQuery(sampleType: dataType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [self.sortDescriptorChronological]) { (query, samples, error) in
                guard let samples = samples as? [HKCategorySample], error == nil else {
                    continuation.resume(throwing: error ?? NSError(domain: "HealthKitFetch", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                    return
                }
                
                    let selfreportedDataList = samples.map { AppleHealthSefReportModel(startdate: $0.startDate, intensity: $0.value ) }
                    continuation.resume(returning: selfreportedDataList)
            
                
            }
            
            self.healthStore.execute(query)
        }
    }
    
    func fetchAppetiteChanges(startDate: Date, endDate: Date) async throws -> [AppetiteChangeModel]{
        guard let dataType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.appetiteChanges) else {
            print("Data type of name Appetite Change not available")
            return []
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])
            let query = HKSampleQuery(sampleType: dataType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [self.sortDescriptorChronological]) { (query, samples, error) in
                guard let samples = samples as? [HKCategorySample], error == nil else {
                    continuation.resume(throwing: error ?? NSError(domain: "HealthKitFetch", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                    return
                }
                
                    let selfreportedDataList = samples.map { AppetiteChangeModel(startdate: $0.startDate, intensity: $0.value ) }
                    continuation.resume(returning: selfreportedDataList)
                
            }
            
            self.healthStore.execute(query)
        }
    }
        
    
    func fetchPeriodData(startDate : Date, endDate : Date) async throws -> [PeriodSampleModel]{
         guard let menstrualFlowType = HKObjectType.categoryType(forIdentifier: .menstrualFlow) else {
             print("Menstrual Flow type not available")
             return []
         }

        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])
            let query = HKSampleQuery(sampleType: menstrualFlowType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [self.sortDescriptorChronological]) { (query, samples, error) in
                guard let samples = samples as? [HKCategorySample], error == nil else {
                    continuation.resume(throwing: error ?? NSError(domain: "HealthKitFetch", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                    return
                }
                
                let periodDataList = samples.map {PeriodSampleModel(startdate: $0.startDate, value: $0.value, startofPeriod: $0.metadata?["HKMenstrualCycleStart"]! as! Int) }
                
                    continuation.resume(returning: periodDataList)
                }
                
                self.healthStore.execute(query)
            }
        }
     
    
    func fetchSleepData(startDate: Date, endDate: Date) async throws -> [SleepDataModel]{
         guard let sleepAnalysisType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
             print("Sleep Analysis type not available")
             return []
         }
        let startDate = Calendar.current.date(byAdding: .hour, value: -12, to: startDate)!
            
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])
            let query = HKSampleQuery(sampleType: sleepAnalysisType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [self.sortDescriptorChronological]) { (query, samples, error) in
                
                guard let samples = samples as? [HKCategorySample], error == nil else {
                    continuation.resume(throwing: error ?? NSError(domain: "HealthKitFetch", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                    return
                }
                
                let sleepDataList = samples.map {SleepDataModel(startDate: $0.startDate, endDate: $0.endDate, value: $0.value) }
                
                continuation.resume(returning: sleepDataList)
                }
                
                self.healthStore.execute(query)
            }
        }
    
    func simplifySleepDataToSleepLength(sleepDataModel: [SleepDataModel]) -> [Date: Int] {
        var sleepLengthDict : [Date : Double] = [:]
        let datesDuration = sleepDataModel.map {($0.startDate, $0.duration, $0.label)}
        if datesDuration.count == 0 {
            return [:]
        }
        let firstDate = datesDuration[0].0
        let previousDateComponent = Calendar.current.dateComponents([.day, .month, .year], from: firstDate)
        var cutOff = Calendar.current.date(from: DateComponents(year: previousDateComponent.year, month: previousDateComponent.month, day: previousDateComponent.day, hour: 12, minute: 00, second: 00))! // Cut of when one sleep cycle can be is at noon
        sleepLengthDict[cutOff] = 0

        for tuples in datesDuration{
            // Check detailed sleep data
            while cutOff < tuples.0 {
                cutOff = Calendar.current.date(byAdding: .hour, value: 24, to: cutOff)!
                sleepLengthDict[cutOff] = 0
            }
            if tuples.2.contains("asleep"){
                sleepLengthDict[cutOff] = sleepLengthDict[cutOff]! + tuples.1
            }
        }
        
        cutOff = Calendar.current.date(from: DateComponents(year: previousDateComponent.year, month: previousDateComponent.month, day: previousDateComponent.day, hour: 12, minute: 00, second: 00))!
        // Only "in bed" available
        var considerThisDay = (sleepLengthDict[cutOff] == 0)
        for tuples in datesDuration{
            while cutOff < tuples.0 {
                cutOff = Calendar.current.date(byAdding: .hour, value: 24, to: cutOff)!
                considerThisDay = (sleepLengthDict[cutOff] == 0)
            }
            if considerThisDay {
                sleepLengthDict[cutOff] = sleepLengthDict[cutOff]! + tuples.1
            }
        }

        var sleepLengthDictInt : [Date:Int] = [:]
        for key in sleepLengthDict.keys{
            sleepLengthDictInt[key] = Int(sleepLengthDict[key]!)
        }
    
        sleepLengthDictInt.removeValue(forKey: sleepLengthDictInt.keys.sorted()[0])
        sleepLengthDictInt.removeValue(forKey: sleepLengthDictInt.keys.sorted()[sleepLengthDictInt.keys.count - 1])
        
        return sleepLengthDictInt
    }
        
    
    func fetchTempData(){
        // Currently not used
        guard let wristSkinTemperatureType = HKObjectType.quantityType(forIdentifier: .appleSleepingWristTemperature) else {
            print("Wrist Skin temperature type not available")
            return
        }
    
        
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .month, value: -6, to: Date())!
        let endDate = Date()

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: wristSkinTemperatureType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let samples = samples as? [HKQuantitySample] {
                for sample in samples {
                    let temperature = sample.quantity.doubleValue(for: HKUnit.degreeCelsius())
                    let date = sample.startDate
                    print("Wrist Skin Temperature: \(temperature) °C on \(date)")
                }
            } else {
                // Handle the error
                print("Failed to fetch basal body temperature data: \(String(describing: error))")
            }
        }

        healthStore.execute(query)
        
    }
    
    
    func fetchCollectedQuantityData(startDate: Date, endDate: Date,  dataName: HKQuantityTypeIdentifier) async throws -> [Date : Int]{
        //.stepcount .appleExerciseTime
        guard let dataType = HKObjectType.quantityType(forIdentifier: dataName) else {
            print("Data type \(dataName) not available")
            return [:]
        }
        var dateComponents = DateComponents()
        dateComponents.day = 1
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [ .strictEndDate])
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(quantityType: dataType,
                                                    quantitySamplePredicate: predicate,
                                                    options: .cumulativeSum,
                                                    anchorDate: startDate,
                                                    intervalComponents: dateComponents)
                    
                    query.initialResultsHandler = { query, results, error in
                        guard let results = results, error == nil else {
                            continuation.resume(throwing: error ?? NSError(domain: "HealthKitFetch", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                            return
                        }
                        
                        var quantityOverTime: [Date: Int] = [:]
                        results.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                            if let sum = statistics.sumQuantity() {
                                
                                var count = -1
                                
                                if (dataName == HKQuantityTypeIdentifier.stepCount){
                                    count = Int(sum.doubleValue(for: HKUnit.count()))
                                }
                                else if (dataName == HKQuantityTypeIdentifier.appleExerciseTime){
                                    count =  Int(sum.doubleValue(for: .minute()))
                                }
                                else {
                                    print("Error: There is no way to sum over this unit for quantity query")
                                }
                                
                                let date = statistics.startDate // Timezone conversions (Our day goes from dd -1 .mm 22:00 +00 to dd.mm 22:00) - Display Function takes care of it
    
                                quantityOverTime[date] = count
                            }
                        }
                        
                        continuation.resume(returning: quantityOverTime)
                    }
                    
                    self.healthStore.execute(query)
                }
        }
}


