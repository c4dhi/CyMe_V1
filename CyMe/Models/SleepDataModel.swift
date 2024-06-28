//
//  SleepDataModel.swift
//  CyMe
//
//  Created by Deborah on 29.05.2024.
//

import Foundation
import HealthKit


struct SleepDataModel {
    var startDate: Date
    var endDate: Date
    var duration: Double   // in Seconds
    var cathegory: HKCategoryValueSleepAnalysis
    var label: String
    
    
    init(startDate: Date, endDate: Date, value: Int) {
        self.startDate = startDate
        self.endDate = endDate
        
        self.duration = endDate.timeIntervalSince(startDate)
        
        let sleepValueCathegories = [0: HKCategoryValueSleepAnalysis.inBed, 1: HKCategoryValueSleepAnalysis.asleepUnspecified, 2: HKCategoryValueSleepAnalysis.awake, 3: HKCategoryValueSleepAnalysis.asleepCore, 4: HKCategoryValueSleepAnalysis.asleepDeep , 5: HKCategoryValueSleepAnalysis.asleepREM]
        self.cathegory = sleepValueCathegories[value]!
        
        let sleepValueLabels = [0: "in bed", 1: "asleep - unspecified", 2: "awake", 3: "asleep - core", 4: "asleep - deep" , 5: "asleep - REM"]
        self.label = sleepValueLabels[value]!
        }
     
    static func formatDuration(duration: Double) -> String{
        if duration < 60 {
            return "\(Int(duration))s"
        }
        if duration < 3600 {
            let sec = duration.truncatingRemainder(dividingBy: 60)
            let min = (duration - sec)/60
            
            return "\(Int(min))min \(Int(sec))s"
        }
        
        else {
            let sec = duration.truncatingRemainder(dividingBy: 60)
            let min_incl_h = (duration - sec)/60
            let min = min_incl_h.truncatingRemainder(dividingBy: 60)
            let hours = (min_incl_h - min)/60
            
            return "\(Int(hours))h \(Int(min))min \(Int(sec))s"
        }
    }
    
    
    func print() {
        let formatedDate = DateFormatter.localizedString(from: startDate, dateStyle: .short, timeStyle: .short)
        Swift.print("(\(formatedDate), Duration: \(duration)s, \(SleepDataModel.formatDuration(duration:duration)), \(label) )")
    }

    }
