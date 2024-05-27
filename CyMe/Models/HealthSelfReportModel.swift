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
    
    func print() {
        let formatedDate = DateFormatter.localizedString(from: startdate, dateStyle: .short, timeStyle: .short)
        Swift.print("(\(formatedDate), \(symptomPresent), \(intensity))")
    }

    }
