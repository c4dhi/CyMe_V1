//
//  HealthSelfReportModel.swift
//  CyMe
//
//  Created by Deborah on 27.05.2024.
//

import Foundation

struct AppleHealthSefReportModel {
    var startdate: Date
    var symptomPresent: Bool
    var intensity: Int
    var label: String
    
    
    init(startdate: Date, intensity: Int) {
        self.startdate = startdate
        self.intensity = intensity
        
        let selfreportIntensityLabels = [1: "Nicht vorhanden", 0: "Vorhanden", 2: "Leicht", 3: "Mittel", 4: "Stark"]
        self.label = selfreportIntensityLabels[intensity] ?? "No intensity Label"

        self.symptomPresent = (intensity != 1)
        }
    
    func print() {
        let formatedDate = DateFormatter.localizedString(from: startdate, dateStyle: .short, timeStyle: .short)
        Swift.print("(\(formatedDate), \(intensity), \(label), Symptom present: \(symptomPresent))")
    }

    }
