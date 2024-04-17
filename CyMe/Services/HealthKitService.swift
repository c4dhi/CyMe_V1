//
//  DiscoveryService.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//  TODO do here the interaction with the health kit

import HealthKit

class HealthKitService {
    let healthStore = HKHealthStore()
    
    // Function to request authorization for accessing HealthKit data
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Code to request authorization...
    }
    
    // Function to fetch health data
    func fetchHealthData(completion: @escaping ([HealthDataModel]?, Error?) -> Void) {
        // Code to fetch health data...
    }
}

