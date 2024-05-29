//
//  PeriodSampleModel.swift
//  CyMe
//
//  Created by Deborah on 27.05.2024.
//

import Foundation
import HealthKit

struct PeriodSampleModel {
    var startdate: Date
    var cathegory: HKCategoryValueMenstrualFlow
    var label: String
    var startofPeriod : Bool
    var bleedingPresent: Bool
   
    
    init(startdate: Date, value: Int, startofPeriod: Int) {
        self.startdate = startdate
        
        let periodCathegory = [1: HKCategoryValueMenstrualFlow.unspecified, 2: HKCategoryValueMenstrualFlow.light, 3: HKCategoryValueMenstrualFlow.medium, 4: HKCategoryValueMenstrualFlow.heavy, 5: HKCategoryValueMenstrualFlow.none]
        self.cathegory = periodCathegory[value]!
        
        let periodValueLabels = [1: "Vorhanden", 2: "Leicht", 3: "Mittel", 4: "Stark", 5: "Nicht vorhanden"]
        self.label = periodValueLabels[value] ?? "No value Label"

        
        self.startofPeriod = (startofPeriod == 1)
        self.bleedingPresent = (value != 5)
        }
     
    
    func print() {
        let formatedDate = DateFormatter.localizedString(from: startdate, dateStyle: .short, timeStyle: .none)
        Swift.print("(\(formatedDate), \(label), Bleeding: \(bleedingPresent), Start: \(startofPeriod))")
    }

    }
