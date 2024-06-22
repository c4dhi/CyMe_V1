//
//  AppetiteChangeModel.swift
//  CyMe
//
//  Created by Deborah on 17.06.2024.
//

import Foundation
import HealthKit

struct AppetiteChangeModel : DataProtocoll {
    var startdate: Date
    var appetiteChangePresent: Bool
    var intensity: Int
    var appetiteChangeCathegory: HKCategoryValueAppetiteChanges
    var label: String
    
    
    init(startdate: Date, intensity: Int) {
        self.startdate = startdate
        self.intensity = intensity
 
        let selfreportedAppetiteChangeCathegory = [1:  HKCategoryValueAppetiteChanges.noChange, 0:  HKCategoryValueAppetiteChanges.unspecified, 2:  HKCategoryValueAppetiteChanges.decreased, 3:  HKCategoryValueAppetiteChanges.increased ]
        self.appetiteChangeCathegory = selfreportedAppetiteChangeCathegory[intensity]!
        
        let selfreportIntensityLabels = [1:  "no Change", 0:  "unspecified", 2:  "decreased", 3:  "increased" ] 
        self.label = selfreportIntensityLabels[intensity] ?? "No intensity Label"
        
        self.appetiteChangePresent = (intensity != 1)
        }
    
    func print() {
        let formatedDate = DateFormatter.localizedString(from: startdate, dateStyle: .short, timeStyle: .short)
        Swift.print("(\(formatedDate), \(label), Symptom present: \(appetiteChangePresent))")
    }

    }
