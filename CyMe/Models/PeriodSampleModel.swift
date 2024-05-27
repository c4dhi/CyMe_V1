//
//  PeriodSampleModel.swift
//  CyMe
//
//  Created by Deborah on 27.05.2024.
//

import Foundation

struct PeriodSampleModel {
    var startdate: Date
    var intensity: Int
    var startofPeriod : Bool
    var bleedingPresent: Bool
   
    
    
    init(startdate: Date, intensity: Int, startofPeriod: Int) {
        self.startdate = startdate
        self.intensity = intensity
        self.startofPeriod = (startofPeriod == 1)
        self.bleedingPresent = (intensity != 5)
        }
     
    
    func print() {
        let formatedDate = DateFormatter.localizedString(from: startdate, dateStyle: .short, timeStyle: .short)
        Swift.print("(\(formatedDate), \(intensity), \(bleedingPresent), Start: \(startofPeriod))")
    }

    }
