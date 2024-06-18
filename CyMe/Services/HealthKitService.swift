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
    
    // TODO Make sure fetch will be asynch soon
    
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
    
    
    
    // Helper function - nice display with a dictionary which has date as a key
    func displayDateDictionary(dict: [Date: Any]){
        for consideredDate in dict.keys.sorted(){
            print(DateFormatter.localizedString(from: consideredDate, dateStyle: .short, timeStyle: .none), terminator: "")
            if let value = dict[consideredDate]{
                print(": \(value) ")}
            else {print("There is a problem with displaying dict objects")}
        }
    }
    
    
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
    
    
    func get_health_data() async {
        let amountOfDays = 5
        let startOfToday = Calendar.current.startOfDay(for: Date()) // Start of today (has date of yesterday because of timezones)
        let endDate = Calendar.current.date(byAdding: .day, value: +1, to: startOfToday)! // end of today
        let startDate = Calendar.current.date(byAdding: .day, value: -amountOfDays, to: endDate)!
        
        
        // We fetch some selfreported data
        
        var selfreportDataList : [AppleHealthSefReportModel] = []
        do {
            selfreportDataList = try await fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.headache)
        } catch {
            print("Error: \(error)")
        }
        for data in selfreportDataList{
            data.print()
        }
         
        // Possible Data names:
            // HKCategoryTypeIdentifier.headache)
            // HKCategoryTypeIdentifier.abdominalCramps) // Bauchkrämpfe
            // HKCategoryTypeIdentifier.lowerBackPain) // Kreuzschmerzen
            // HKCategoryTypeIdentifier.pelvicPain) // Unterleibsschmerzen
            // HKCategoryTypeIdentifier.acne)
            // HKCategoryTypeIdentifier.chestTightnessOrPain) // Engegefühl oder Schmerzen in der Brust
        
        // We fetch some appetite changes data - tested
        /*
        var appetiteChangeDataList : [AppetiteChangeModel] = []
        do {
            appetiteChangeDataList = try await fetchAppetiteChanges()
        } catch {
            print("Error: \(error)")
        }
        for data in appetiteChangeDataList{
            data.print()
        }
         */
       

        
        
        
        
        // Write some data
        //writeSelfreportedSamples(dataName: HKCategoryTypeIdentifier.memoryLapse)
        // TODO not all of these are tested
        
        
        
        // We fetch sleep data - tested
        /*
         var sleepDataList : [SleepDataModel] = []
         do {
         sleepDataList = try await fetchSleepData()
         } catch {
         print("Error: \(error)")
         }
         for sleep in sleepDataList{
         sleep.print()
         }
         */
        
        
        
        // We fetch period data - tested
        /*
         var periodDataList : [PeriodSampleModel] = []
         do {
         periodDataList = try await fetchPeriodData()
         } catch {
         print("Error: \(error)")
         }
         for period in periodDataList{
         period.print()
         }
         */
        
        
        
        // Fetch some automatically generated data - tested
        /*
         var exerciseTime : [Date : Int]? = [:]
         do {
         exerciseTime = try await fetchCollectedQuantityData(startDate: startDate, endDate: endDate, dataName: HKQuantityTypeIdentifier.appleExerciseTime)
         } catch {
         print("Error: \(error)")
         }
         displayDateDictionary(dict: exerciseTime!)
         
         var stepCounts: [Date : Int]? = [:]
         do {
         stepCounts = try await fetchCollectedQuantityData(startDate: startDate, endDate: endDate, dataName: HKQuantityTypeIdentifier.stepCount)
         } catch {
         print("Error: \(error)")
         }
         displayDateDictionary(dict: stepCounts!)
         */
        
    }
    
    func getSymptomes() -> [SymptomModel]  {
        // TODO get symptomes
        return [
            SymptomModel(
                title: "Headache",
                cycleOverview: [0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1],
                hints: ["Most frequent in period phase"],
                min: 0,
                max: 3,
                average: 1,
                covariance: 2.5,
                covarianceOverview: [[2, 3, 4, 6, 5], [1, 2, 3, 4, 5]],
                questionType: .painEmoticonRating
            ),
            SymptomModel(
                title: "Fatigue",
                cycleOverview: [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
                hints: ["Most frequent in luteal phase"],
                min: 1,
                max: 4,
                average: 2,
                covariance: 1.8,
                covarianceOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
                questionType: .intensity
            ),
            SymptomModel(
                title: "Menstruation",
                cycleOverview: [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
                hints: ["Most frequent in luteal phase"],
                min: 1,
                max: 4,
                average: 2,
                covariance: 1.8,
                covarianceOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
                questionType: .menstruationEmoticonRating
            ),
            SymptomModel(
                title: "Mood",
                cycleOverview: [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
                hints: ["Most frequent in luteal phase"],
                min: 1,
                max: 4,
                average: 2,
                covariance: 1.8,
                covarianceOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
                questionType: .emoticonRating
            ),
            SymptomModel(
                title: "Sleep",
                cycleOverview: [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
                hints: ["Most frequent in luteal phase"],
                min: 1,
                max: 4,
                average: 2,
                covariance: 1.8,
                covarianceOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
                questionType: .amountOfhour
            )
        ]
        
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
    
    
    func fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier) async throws -> [AppleHealthSefReportModel]{
        guard let dataType = HKObjectType.categoryType(forIdentifier: dataName) else {
            print("Data type of name (\(dataName) not available")
            return []
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: dataType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [self.sortDescriptorChronological]) { (query, samples, error) in
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
    
    func fetchAppetiteChanges() async throws -> [AppetiteChangeModel]{
        guard let dataType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.appetiteChanges) else {
            print("Data type of name Appetite Change not available")
            return []
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: dataType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [self.sortDescriptorChronological]) { (query, samples, error) in
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
     
    
    func fetchSleepData() async throws -> [SleepDataModel]{
         guard let sleepAnalysisType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
             print("Sleep Analysis type not available")
             return []
         }
            
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepAnalysisType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [self.sortDescriptorChronological]) { (query, samples, error) in
                
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
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
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


