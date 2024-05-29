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
    
    var stepCountOverTime: [Date: Int] = [:] // A dictionary with Date:Stepcount of that day, is updated whenever the fetchStepcount function is called
    
    // TODO Add all types we want to read and write
    private let typesToRead: Set<HKSampleType> = [HKObjectType.quantityType(forIdentifier: .stepCount)!,HKObjectType.categoryType(forIdentifier: .headache)!, HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!, HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!, HKObjectType.categoryType(forIdentifier: .menstrualFlow)!]
    private let typesToWrite: Set<HKSampleType> = [HKObjectType.categoryType(forIdentifier: .memoryLapse)!]
    
    // Variables for development
    private let enablePrintStatement = true
    
    
    
    // Helper function - nice display with a dictionary which has date as a key
    func displayDateDictionary(dict: [Date: Int]){
        print("[", terminator: "")
        for consideredDate in dict.keys.sorted(){
            print(DateFormatter.localizedString(from: consideredDate, dateStyle: .short, timeStyle: .none), terminator: "")
            if let value = dict[consideredDate]{
                print(": \(value), ", terminator: "")}
            else {print("There is a problem with displaying all dict objects")}
        }
        print("]")
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
        // Fetch some automatically generated data
        //fetchStepCount(amountOfDays: 5)
        if self.enablePrintStatement {displayDateDictionary(dict: self.stepCountOverTime)} // Will need two times, but only updates with function
        // We fetch some data
        //fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.headache)
        //fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.memoryLapse)
        // We write some data
        //writeSelfreportedSamples(dataName: HKCategoryTypeIdentifier.memoryLapse)
        // We fetch the period data
        //fetchPeriodData()
        fetchSleepData()
        //fetchTrainingMinutes(amountOfDays: 5)
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
    
    
    func fetchStepCount(amountOfDays: Int) {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            print("Step count type not available")
            return
        }

        let now = Date()
        let startOfToday = Calendar.current.startOfDay(for: now)
      
        for i in 0...amountOfDays-1{
            
            var stepCount = 0
            
            if let startOfConsideredDay = Calendar.current.date(byAdding: .day, value: -i, to: startOfToday){
                // To get from the beginning to the end of a day, there are 24 hours
                if let endOfConsideredDay = Calendar.current.date(byAdding: .hour, value: 24, to: startOfConsideredDay){
                    
                    let predicate = HKQuery.predicateForSamples(withStart: startOfConsideredDay, end: endOfConsideredDay,  options: .strictEndDate)
                    
                    let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
                        guard let result = result, let sum = result.sumQuantity() else {
                            if let error = error {
                                print("Error fetching step count: \(error.localizedDescription)")
                                self.stepCountOverTime[startOfConsideredDay] =  0
                            }
                            return
                        }
                        
                        stepCount = Int(sum.doubleValue(for: HKUnit.count()))
                        if self.enablePrintStatement {print("Step count: \(stepCount), date: \(startOfConsideredDay)")} // Remember the day might be +1 since we are not in the same timezone
                        self.stepCountOverTime[startOfConsideredDay] =  stepCount
                        
                    }
                    healthStore.execute(query)
                    
                }
                else{
                    print("Computation of end of considered day failed critically")
                }
            }
            else{
                print("Computation of start of considered day failed critically")
            }
        }
    }

    
    func fetchTrainingMinutes(amountOfDays: Int) {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) else {
            print("Training minutes type not available")
            return
        }

        let now = Date()
        let startOfToday = Calendar.current.startOfDay(for: now)
      
        for i in 0...amountOfDays-1{
            
            var stepCount = 0
            
            if let startOfConsideredDay = Calendar.current.date(byAdding: .day, value: -i, to: startOfToday){
                // To get from the beginning to the end of a day, there are 24 hours
                if let endOfConsideredDay = Calendar.current.date(byAdding: .hour, value: 24, to: startOfConsideredDay){
                    
                    let predicate = HKQuery.predicateForSamples(withStart: startOfConsideredDay, end: endOfConsideredDay,  options: .strictEndDate)
                    /*
                    let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
                        guard let result = result, let sum = result.sumQuantity() else {
                            if let error = error {
                                print("Error fetching step count: \(error.localizedDescription)")
                                self.stepCountOverTime[startOfConsideredDay] =  0
                            }
                            return
                        }
                        
                        stepCount = Int(sum.doubleValue(for: HKUnit.count()))
                        if self.enablePrintStatement {print("Step count: \(stepCount), date: \(startOfConsideredDay)")} // Remember the day might be +1 since we are not in the same timezone
                        self.stepCountOverTime[startOfConsideredDay] =  stepCount
                        */

                    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
                    
                    let query = HKSampleQuery(sampleType: stepCountType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                        guard let samples = samples else {
                            if let error = error {
                                print("Error fetching sleep analysis data: \(error.localizedDescription)")
                            }
                            return
                        }
                        
                        for sample in samples {
                            
                            let sleepSample = sample
                            let startDate = sleepSample.startDate
                            let endDate = sleepSample.endDate
                            let value = sleepSample.sampleType
                                
                            print(startDate)
                            print(endDate)
                            print(value)
                                
                                
                            }
                    
                    
                    }
                    healthStore.execute(query)
                    
                    
                    
                }
                else{
                    print("Computation of end of considered day failed critically")
                }
            }
            else{
                print("Computation of start of considered day failed critically")
            }
        }
    }
    
    
}

