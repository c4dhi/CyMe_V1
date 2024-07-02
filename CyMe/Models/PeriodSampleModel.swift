//
//  PeriodSampleModel.swift
//  CyMe
//
//  Created by Deborah on 27.05.2024.
//

import Foundation
import HealthKit

struct PeriodSampleModel : DataProtocoll {
    var startdate: Date
    var cathegory: HKCategoryValueMenstrualFlow
    var label: String
    var startofPeriod : Bool
    var intensity : Int
    var symptomPresent: Bool // Bleeding Present
   
    
    init(startdate: Date, value: Int, startofPeriod: Int) {
        self.startdate = startdate
        self.intensity = value
        
        let periodCathegory = [1: HKCategoryValueMenstrualFlow.unspecified, 2: HKCategoryValueMenstrualFlow.light, 3: HKCategoryValueMenstrualFlow.medium, 4: HKCategoryValueMenstrualFlow.heavy, 5: HKCategoryValueMenstrualFlow.none]
        self.cathegory = periodCathegory[value]!
        
        let periodValueLabels = [1: "Vorhanden", 2: "Leicht", 3: "Mittel", 4: "Stark", 5: "Nicht vorhanden"]
        self.label = periodValueLabels[value] ?? "No value Label"

        
        self.startofPeriod = (startofPeriod == 1)
        self.symptomPresent = (value != 5)
        }
     
    
    func print() {
        let formatedDate = DateFormatter.localizedString(from: startdate, dateStyle: .short, timeStyle: .none)
        Swift.print("(\(formatedDate), \(label), Bleeding: \(symptomPresent), Start: \(startofPeriod))")
    }

    }

extension Array where Element == PeriodSampleModel {
    func filterByPeriodStart(isStart: Bool) -> [PeriodSampleModel] {
        return self.filter { $0.startofPeriod == isStart }
    }
}
