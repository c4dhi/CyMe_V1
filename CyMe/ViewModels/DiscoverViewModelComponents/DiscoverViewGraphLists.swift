//
//  DiscoverViewGraphLists.swift
//  CyMe
//
//  Created by Deborah on 27.06.2024.
//

import Foundation


// Collected Health Data - Dictionaries
func buildcollectedDataGraphArray(symptomList: [Date: Int], dateRange: [Date], sleepLength : Bool = false) -> [Int?]{
    var dataGraphArray : [Int?] = []
    
    if !sleepLength{
        let firstDate = Calendar.current.date(byAdding: .hour, value: -12, to: dateRange[0])!
        dataGraphArray.append(symptomList[firstDate] ?? nil)
    }
    
    
    for date in dateRange.sorted(){
        // daterange entries are at 10:00 +0000 and symptom list entries are at 22:00 +0000
        // except for sleep length
        var dateToCheck : Date
        
        if !sleepLength {
            dateToCheck = Calendar.current.date(byAdding: .hour, value: 12, to: date)!
        }
        else {
            dateToCheck = date
        }
        
        dataGraphArray.append(symptomList[dateToCheck] ?? nil)
        }
    if !sleepLength {
        dataGraphArray.removeLast() // Ignore the last 0 entry since it belongs to the next day
    }
    return dataGraphArray
}

// Apple Selfreported Symptoms - Lists
func buildSymptomGraphArray(symptomList: [DataProtocoll], dateRange : [Date], appetiteChange : Bool = false) -> [Int?]{
    let datesWithSymptom  = symptomList.map {Calendar.current.dateComponents([.day, .month, .year], from: $0.startdate)}
    
    var symptomGraphArray : [Int?] = []
    let intensityMappingAppleHealthToCyMe : [Int : Int?] = [1: nil, 0: 2, 2: 1, 3: 2, 4: 3]
    let intensityMappingAppetiteChangeToCyMe : [Int : Int?] = [1: nil, 0:0, 2:-1, 3:1]
     
    for date in dateRange{
        if datesWithSymptom.contains(Calendar.current.dateComponents([.day, .month, .year], from: date)){
            let dailySymptomList = symptomList.filterByStartDate(startDate: date)
            
            var consideredSymptom : DataProtocoll
            if dailySymptomList.count > 1{
                // For multiple reports in a day we choose the most intense one
                var maxIntensitySymptom = dailySymptomList[0]
                for symptom in dailySymptomList{
                    if symptom.intensity == 1 { // Not present is the weakest, strictly smallest cathegory, everything is more intense than "not present"
                        continue
                    }
                    if symptom.intensity > maxIntensitySymptom.intensity{
                        maxIntensitySymptom = symptom
                    }
                }
                consideredSymptom = maxIntensitySymptom
            }
            else {
                consideredSymptom = dailySymptomList[0]
            }
            
            let appleHealthIntensity = consideredSymptom.intensity
            if appetiteChange{
                symptomGraphArray.append((intensityMappingAppetiteChangeToCyMe[appleHealthIntensity]!))
            }
            else{
                symptomGraphArray.append(intensityMappingAppleHealthToCyMe[appleHealthIntensity]!)
            }
            
        }
        else{
            symptomGraphArray.append(nil) 
        }
    }
    return symptomGraphArray
}

// CyMe Selfreported Symptoms - Lists
func buildCyMeGraphArray(symptomList: [DataProtocoll], dateRange : [Date], period : Bool = false) -> [Int?]{
    let datesWithSymptom  = symptomList.map {Calendar.current.dateComponents([.day, .month, .year], from: $0.startdate)}
    
    let periodIntensityConversion = [1:2, 2:1, 3:2, 4:3, 5:0]
    
    var symptomGraphArray : [Int?] = []
     
    for date in dateRange{
        if datesWithSymptom.contains(Calendar.current.dateComponents([.day, .month, .year], from: date)){
            var dailySymptomList = symptomList.filterByStartDate(startDate: date)
            
            // For multiple reports in a day we choose the average
            var sumOfIntensities = 0.0
            for symptom in dailySymptomList{
                
                var intensity : Int
                
                if period {intensity = periodIntensityConversion[symptom.intensity]!}
                else {intensity = symptom.intensity}
                
                sumOfIntensities += Double(intensity)
            }
            let  average = sumOfIntensities/Double(dailySymptomList.count) // The average of a single value still makes sense
            if average < 0 { // We always choose to display the more intense option
                symptomGraphArray.append(Int(floor(average)))
            }
            else {
                symptomGraphArray.append(Int(ceil(average)))
            }
            
        }
        else{
            symptomGraphArray.append(nil)
        }
    }
    return symptomGraphArray
}



