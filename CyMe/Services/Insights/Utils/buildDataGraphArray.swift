//
//  buildDataGraphArray.swift
//  CyMe
//
//  Created by Deborah on 04.08.2024.
//

import Foundation

/// Collected Health Data - Dictionaries
func buildDataGraphArray(symptomList: [Date: Int], dateRange: [Date], type : availableHealthMetrics) -> [Int?]{
    var dataGraphArray : [Int?] = []
    
    if dateRange.count == 0{
        return []
    }
    
    for date in dateRange.sorted(){
        var dateToCheck : Date
        if type == .sleepLength {
            // daterange entries are at 22:00 +0000 and symptom dict entries are at 22:00 +0000
            // except for sleep length entrys are at n-1 10:00 +0000
            dateToCheck = Calendar.current.date(byAdding: .hour, value: -12, to: date)!
        }
        else {
            dateToCheck = date
        }
        
        var toAppend : Int?
        
        if symptomList[dateToCheck] != 0 {
            if type != .sleepLength {
                toAppend = symptomList[dateToCheck] ?? nil
            }
            else{
                toAppend = sleepSecondsToHours(seconds : symptomList[dateToCheck] ?? nil)
            }
        }
        else {
            toAppend = nil
        }
        dataGraphArray.append(toAppend)
        }
    
    return dataGraphArray
}

/// Selfreported Symptoms - Lists
func buildDataGraphArray(symptomList: [DataProtocoll], dateRange : [Date], type : availableHealthMetrics) -> [Int?]{
    let datesWithSymptom  = symptomList.map {Calendar.current.dateComponents([.day, .month, .year], from: $0.startdate)}
    
    let intensityMappingPeriodToCyMe = [1:2, 2:1, 3:2, 4:3, 5:0]
    let intensityMappingAppleHealthToCyMe : [Int : Int?] = [1: nil, 0: 2, 2: 1, 3: 2, 4: 3]
    let intensityMappingAppetiteChangeToCyMe : [Int : Int?] = [1: nil, 0:0, 2:-1, 3:1]
    
    var symptomGraphArray : [Int?] = []
     
    for date in dateRange{
        if datesWithSymptom.contains(Calendar.current.dateComponents([.day, .month, .year], from: date)){
            let dailySymptomList = symptomList.filterByStartDate(startDate: date)
            
            // For multiple reports in a day we choose the average
            var sumOfIntensities = 0.0
            for symptom in dailySymptomList{
                var intensity : Int
                
                if type == .appetiteChange { intensity = (intensityMappingAppetiteChangeToCyMe[symptom.intensity]!) ?? 0 }
                else if type == .menstrualBleeding { intensity = intensityMappingPeriodToCyMe[symptom.intensity]! }
                else if [.mood, .sleepQuality, .stress].contains(type){
                    intensity = symptom.intensity
                }
                else{ // Apple Selfreported
                    intensity = (intensityMappingAppleHealthToCyMe[symptom.intensity])! ?? 0
                }
                sumOfIntensities += Double(intensity)
            }
            let  average = sumOfIntensities/Double(dailySymptomList.count) // The average of a single value still makes sense
            symptomGraphArray.append(Int(ceil(average)))
        }
        else{
            symptomGraphArray.append(nil)
        }
    }
    return symptomGraphArray
}

