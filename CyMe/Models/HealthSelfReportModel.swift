//
//  HealthSelfReportModel.swift
//  CyMe
//
//  Created by Deborah on 27.05.2024.
//

import Foundation
import HealthKit

struct AppleHealthSefReportModel : DataProtocoll {
    var startdate: Date
    var symptomPresent: Bool
    var intensity: Int
    var intensityCathegory: HKCategoryValueSeverity
    var label: String
    
    
    init(startdate: Date, intensity: Int) {
        self.startdate = startdate
        
        self.intensity = intensity
        
        let selfreportedIntensityCathegory = [1:  HKCategoryValueSeverity.notPresent, 0:  HKCategoryValueSeverity.unspecified, 2:  HKCategoryValueSeverity.mild, 3:  HKCategoryValueSeverity.moderate, 4:  HKCategoryValueSeverity.severe]
        self.intensityCathegory = selfreportedIntensityCathegory[intensity]!
        
        let selfreportIntensityLabels = [1: "Not present", 0: "present", 2: "mild", 3: "moderate", 4: "severe"]
        self.label = selfreportIntensityLabels[intensity] ?? "No intensity Label"

        self.symptomPresent = (intensity != 1)
        }
    
    func print() {
        let formatedDate = DateFormatter.localizedString(from: startdate, dateStyle: .short, timeStyle: .short)
        Swift.print("(\(formatedDate), \(label), Symptom present: \(symptomPresent))")
    }

    }
