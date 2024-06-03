//
//  DiscoverViewModel.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//  TODO add here all you need to prepare for the view

import Foundation


class DiscoverViewModel: ObservableObject {
    @Published var symptomes: [SymptomeModel]
    
    var healthKitService: HealthKitService
        
    init() {
        healthKitService = HealthKitService()
        self.symptomes = healthKitService.getSymptomes()
    }
    
}

