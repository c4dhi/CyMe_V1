//
//  CyMeSelfreportModel.swift
//  CyMe
//
//  Created by Deborah on 02.07.2024.
//

import Foundation

struct CyMeSefReportModel : DataProtocoll {
    var symptomPresent: Bool
    var startdate: Date
    var intensity: Int
    var label: String
    
    
    init(startdate: Date, label: String) {
        self.startdate = startdate
        
        self.label = label

        
        let selfreportIntensityLabels = ["Very bad" : -2, "Bad" : -1, "Neutral" : 0, "Well" : 1, "Very well" : 2]
            
        self.intensity = selfreportIntensityLabels[label]!
        
        self.symptomPresent = true // Here we only record the symptoms that exist - there is no recording of a null-quality/a non-report
        }
    
    func print() {
        let formatedDate = DateFormatter.localizedString(from: startdate, dateStyle: .short, timeStyle: .short)
        Swift.print("(\(formatedDate), \(label), Symptom present: \(symptomPresent))")
    }

    }
