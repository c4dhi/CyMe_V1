//
//  DiscoverViewModel.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//  TODO add here all you need to prepare for the view

import Combine

class DiscoverViewModel: ObservableObject {
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
}

