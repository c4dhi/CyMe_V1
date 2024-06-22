//
//  DiscoveryService.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//  TODO do here the interaction with the health kit

import HealthKit
import Foundation
import Combine

class HealthKitService {
    
    
    // General Objects
    private let healthStore = HKHealthStore()
    
    // Create a sort descriptor for a chronological sort
    let sortDescriptorChronological = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
    
    
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
        HKObjectType.quantityType(forIdentifier: .appleSleepingWristTemperature)!]
    
    
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
    private let enablePrintStatement = false
    
    func requestAuthorization() {
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { (success, error) in
            if success {
                // Authorization successful, fetch health data
                //self.get_health_data()
                
            } else {
                // Authorization failed, handle error
                if let error = error {
                    print("Authorization failed: \(error.localizedDescription)")
                }
            }
        }
    }

    
    
    func writeSelfreportedSamples(dataName: HKCategoryTypeIdentifier){
        guard let dataType = HKObjectType.categoryType(forIdentifier: dataName) else {
            print("Data type of name (\(dataName) not available")
            return
        }
        
        let selfreportedSample = HKCategorySample(type: dataType, value: HKCategoryValue.notApplicable.rawValue, start: Date(), end: Date()) // TODO Always gives "vorhanden"
        
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
        
    
    func fetchPeriodData() async throws -> [PeriodSampleModel]{
         guard let menstrualFlowType = HKObjectType.categoryType(forIdentifier: .menstrualFlow) else {
             print("Menstrual Flow type not available")
             return []
         }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: menstrualFlowType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [self.sortDescriptorChronological]) { (query, samples, error) in
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
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate, .strictEndDate])
        
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


