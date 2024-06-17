//
//  DiscoverViewModel.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//  TODO add here all you need to prepare for the view

import Foundation


class DiscoverViewModel: ObservableObject {
    @Published var symptoms: [SymptomModel]
    
    var healthKitService: HealthKitService
        
    init() {
        healthKitService = HealthKitService()
        self.symptoms = healthKitService.getSymptomes()
    }
    
}

