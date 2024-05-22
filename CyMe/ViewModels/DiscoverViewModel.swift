//
//  DiscoverViewModel.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//  TODO add here all you need to prepare for the view

import Combine
import SigmaSwiftStatistics
import HealthKit
import Foundation


class DiscoverViewModel: ObservableObject {
    
    // Typealiases
    typealias selfreportTriple = (Date, Bool, Int) //Startdate, symptom yes or no, Intensity
    
    // General Objects
    private let healthStore = HKHealthStore()
    var stepcountOverTime: [Date: Int] = [:] // A dictionary with Date:Stepcount of that day, is updated whenever the fetchStepcount function is called
    
    // TODO Add all types we want to read and write
    private let typesToRead: Set<HKSampleType> = [HKObjectType.quantityType(forIdentifier: .stepCount)!,HKObjectType.categoryType(forIdentifier: .headache)! ]
    private let typesToWrite: Set<HKSampleType> = [HKObjectType.categoryType(forIdentifier: .memoryLapse)!]
    
    // Variables for development
    private let verbose = true
    
    
    
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
        fetchStepCount(amountOfDays: 5)
        if self.verbose {displayDateDictionary(dict: self.stepcountOverTime)} // Will need two times, but only updates with function
        // We fetch some data
        fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.headache)
        fetchSelfreportedSamples(dataName: HKCategoryTypeIdentifier.memoryLapse)
        // We write some data
        writeSelfreportedSamples(dataName: HKCategoryTypeIdentifier.memoryLapse)
    }
    
    
    func writeSelfreportedSamples(dataName: HKCategoryTypeIdentifier){
        guard let dataType = HKObjectType.categoryType(forIdentifier: dataName) else {
            print("Data type of name (\(dataName) not available")
            return
        }
        
        let selfreportedSample = HKCategorySample(type: dataType, value: HKCategoryValue.notApplicable.rawValue, start: Date(), end: Date()) // TODO Always gives "vorhanden"
        
        healthStore.save(selfreportedSample) { (success, error) in
            if success && self.verbose {
                print("Selfreported sample saved successfully")
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

        // Create a list of triples
        var selfreportedDataList: [selfreportTriple] = []
       
        // Create a sort descriptor for a chronological sort
        let sortDescriptorChronological = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: dataType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptorChronological]) { (query, samples, error) in
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
                    let sampleBool = (intensity != 1)
                    selfreportedDataList.append((startDate, sampleBool, intensity))
                }
            }
            
            if self.verbose {
                print(dataName)
                print(selfreportedDataList)
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
                if let endOfConsideredDay = Calendar.current.date(byAdding: .hour, value: 24, to: startOfConsideredDay){
                    
                    let predicate = HKQuery.predicateForSamples(withStart: startOfConsideredDay, end: endOfConsideredDay,  options: .strictEndDate)
                    
                    let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
                        guard let result = result, let sum = result.sumQuantity() else {
                            if let error = error {
                                print("Error fetching step count: \(error.localizedDescription)")
                                self.stepcountOverTime[startOfConsideredDay] =  0
                            }
                            return
                        }
                        
                        stepCount = Int(sum.doubleValue(for: HKUnit.count()))
                        if self.verbose {print("Step count: \(stepCount), date: \(startOfConsideredDay)")} // Remember the day might be +1 since we are not in the same timezone
                        self.stepcountOverTime[startOfConsideredDay] =  stepCount
                        
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
    
    /*
     private let healthKitService = HealthKitService()
    @Published var healthData: [HealthDataModel] = []
    private var cancellables = Set<AnyCancellable>()
    
    func fetchHealthData() {
        healthKitService.fetchHealthData { [weak self] data, error in
            guard let self = self else { return }
            if let data = data {
                self.healthData = data
            } else if let error = error {
                print("Error fetching health data: \(error.localizedDescription)")
            }
        }
    }
     */
    
}

