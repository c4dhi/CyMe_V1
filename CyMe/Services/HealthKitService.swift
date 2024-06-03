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
                    // Must -  Read Access - QuantityType
                    HKObjectType.quantityType(forIdentifier: .stepCount)!,
                    
                    // Should - Read Access - QuantityType
                    HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!]
    
    
    private let typesToWrite: Set<HKSampleType> = [
                    // Must - Write Access - CategoryType
                    HKObjectType.categoryType(forIdentifier: .menstrualFlow)!,
                    HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
                    HKObjectType.categoryType(forIdentifier: .headache)!,
                    HKObjectType.categoryType(forIdentifier: .abdominalCramps)!,
                    HKObjectType.categoryType(forIdentifier: .lowerBackPain)!,
                    HKObjectType.categoryType(forIdentifier: .pelvicPain)!,
                    HKObjectType.categoryType(forIdentifier: .acne)!,
                    HKObjectType.categoryType(forIdentifier: .chestTightnessOrPain)!]
    
    // Variables for development
    private let enablePrintStatement = false
    
    
    
    // Helper function - nice display with a dictionary which has date as a key
    func displayDateDictionary(dict: [Date: Any]){
        for consideredDate in dict.keys.sorted(){
            print(DateFormatter.localizedString(from: consideredDate, dateStyle: .short, timeStyle: .none), terminator: "")
            if let value = dict[consideredDate]{
                print(": \(value) ")}
            else {print("There is a problem with displaying all dict objects")}
        }
    }
    
    
    func requestAuthorization() {
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { (success, error) in
            if success {
                // Authorization successful, fetch health data
                self.get_health_data()
                
            } else {
                // Authorization failed, handle error
                if let error = error {
                    print("Authorization failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func get_health_data()  {
        // We fetch some selfreported data
        //fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.headache)
        //fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.abdominalCramps) // Bauchkrämpfe
        //fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.lowerBackPain) // Kreuzschmerzen
        //fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.pelvicPain) // Unterleibsschmerzen
        //fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.acne)
        fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.chestTightnessOrPain) // Engegefühl oder Schmerzen in der Brust
        
        // Fetch some automatically generated data
        fetchCollectedQuantityData(amountOfDays: 5, dataName: HKQuantityTypeIdentifier.stepCount)
        //fetchCollectedQuantityData(amountOfDays: 5, dataName: HKQuantityTypeIdentifier.appleExerciseTime)
    
        
        // Write some data
        //writeSelfreportedSamples(dataName: HKCategoryTypeIdentifier.memoryLapse)
        // TODO not all of these are tested
        
        // We fetch period data
        //fetchPeriodData()
        
        // We fetch sleep data
        //fetchSleepData()
        
    }
    
    func getSymptomes() -> [SymptomeModel]  {
        // TODO get symptomes
        return [SymptomeModel(title: "example", cycleOverview: [[0, 1, 2, 3, 0]], hints: ["example"], min: 3, max: 7, average: 4, covariance: 0.8, coverianceOverview: [[0, 1, 2, 3, 0]])]
        
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
    
    
    func fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier){
        guard let dataType = HKObjectType.categoryType(forIdentifier: dataName) else {
            print("Data type of name (\(dataName) not available")
            return
        }

        var selfreportedDataList: [AppleHealthSefReportModel] = []
       
        if self.enablePrintStatement {print(dataName)}
        let query = HKSampleQuery(sampleType: dataType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [self.sortDescriptorChronological]) { (query, samples, error) in
            guard let samples = samples else {
                if let error = error {
                    print("Error fetching selfreported data: \(error.localizedDescription)")
                }
                return
            }
            
            for sample in samples {
                
                // Handle each selfreported sample
                if let selfreportedSample = sample as? HKCategorySample {
                    let startDate = selfreportedSample.startDate
                    let intensity = selfreportedSample.value

                    let SRmodel = AppleHealthSefReportModel(startdate: startDate, intensity: intensity)
                    selfreportedDataList.append(SRmodel)
                    if self.enablePrintStatement {SRmodel.print()}
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    
    func fetchPeriodData() {
         guard let menstrualFlowType = HKObjectType.categoryType(forIdentifier: .menstrualFlow) else {
             print("Menstrual Flow type not available")
             return
         }
        
         var periodDataList: [PeriodSampleModel] = []

        let query = HKSampleQuery(sampleType: menstrualFlowType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [self.sortDescriptorChronological]) { (query, samples, error) in
             guard let samples = samples else {
                 if let error = error {
                     print("Error fetching menstrual flow data: \(error.localizedDescription)")
                 }
                 return
             }
             
             for sample in samples {
                 
                 if let mensSample = sample as? HKCategorySample {
                     let startDate = mensSample.startDate
                     let value = mensSample.value
                     let startOfPeriod = mensSample.metadata?["HKMenstrualCycleStart"]!
                    
                     let periodSampleModel = PeriodSampleModel(startdate: startDate, value: value, startofPeriod: startOfPeriod as! Int)
                     
                     if self.enablePrintStatement{
                         periodSampleModel.print()}
                     
                     periodDataList.append(periodSampleModel)
                    
                 }
             }
         }
         healthStore.execute(query)
        
     }
    
    
    func fetchSleepData() {
         guard let sleepAnalysisType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
             print("Sleep Analysis type not available")
             return
         }
        
         //var periodDataList: [PeriodSampleModel] = []
        
         

         let query = HKSampleQuery(sampleType: sleepAnalysisType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [self.sortDescriptorChronological]) { (query, samples, error) in
             guard let samples = samples else {
                 if let error = error {
                     print("Error fetching sleep analysis data: \(error.localizedDescription)")
                 }
                 return
             }
             
             for sample in samples {
                 
                 if let sleepSample = sample as? HKCategorySample {
                     let startDate = sleepSample.startDate
                     let endDate = sleepSample.endDate
                     let value = sleepSample.value
                     
                     let sleepSampleModel = SleepDataModel(startDate: startDate, endDate: endDate, value: value)
                     
                     if self.enablePrintStatement{sleepSampleModel.print()}
                 }
             }
         }
         healthStore.execute(query)
        
     }
    
    
    func fetchCollectedQuantityData(amountOfDays: Int, dataName: HKQuantityTypeIdentifier) {
        //.stepcount .appleExerciseTime
        guard let dataType = HKObjectType.quantityType(forIdentifier: dataName) else {
            print("Data type \(dataName) not available")
            return
        }
    
        var quantityOverTime: [Date: Int] = [:]
        
        let startOfToday = Calendar.current.startOfDay(for: Date()) // Start of today (has date of yesterday because of timezones)
        let endDate = Calendar.current.date(byAdding: .day, value: +1, to: startOfToday)! // end of today
        let startDate = Calendar.current.date(byAdding: .day, value: -amountOfDays, to: endDate)!
        
        var dateComponents = DateComponents()
        dateComponents.day = 1
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsCollectionQuery(quantityType: dataType,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: startDate,
                                                intervalComponents: dateComponents)
        query.initialResultsHandler = { query, results, error in
          
            if let error = error {
                print("Error fetching \(dataName): \(error.localizedDescription)")
                return
            }
            
            results?.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
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
            if self.enablePrintStatement{ 
                print(dataName.rawValue)
                self.displayDateDictionary(dict: quantityOverTime) }
           
        }
        healthStore.execute(query)
    }
    
}

