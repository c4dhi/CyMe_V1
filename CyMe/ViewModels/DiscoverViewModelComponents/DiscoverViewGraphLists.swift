//
//  DiscoverViewGraphLists.swift
//  CyMe
//
//  Created by Deborah on 27.06.2024.
//

import Foundation


// Collected Health Data - Dictionaries
func buildcollectedDataGraphArray(symptomList: [Date: Int], dateRange: [Date]) -> [Int]{
    var dataGraphArray : [Int] = []
    
    let firstDate = Calendar.current.date(byAdding: .hour, value: -12, to: dateRange[0])!
    dataGraphArray.append(symptomList[firstDate] ?? 0)
    
    for date in dateRange.sorted(){
        // daterange entries are at 10:00 +0000 and symptom list entries are at 22:00 +0000
        let dateToCheck = Calendar.current.date(byAdding: .hour, value: 12, to: date)!
        dataGraphArray.append(symptomList[dateToCheck] ?? 0) // TODO change default in general
        }
    dataGraphArray.removeLast() // Ignore the last 0 entry since it belongs to the next day
    return dataGraphArray
}

// Selfreported Symptoms - Lists
func buildSymptomGraphArray(symptomList: [DataProtocoll], dateRange : [Date], appetiteChange : Bool = false) -> [Int]{
    let datesWithSymptom  = symptomList.map {Calendar.current.dateComponents([.day, .month, .year], from: $0.startdate)}
    
    var symptomGraphArray : [Int] = []
    let intensityMappingAppleHealthToCyMe : [Int : Int] = [1: 0, 0: 2, 2: 1, 3: 2, 4: 3]
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
                symptomGraphArray.append((intensityMappingAppetiteChangeToCyMe[appleHealthIntensity]!) ?? 0 ) //TODO check with nil
            }
            else{
                symptomGraphArray.append(intensityMappingAppleHealthToCyMe[appleHealthIntensity]!)
            }
            
        }
        else{
            symptomGraphArray.append(0) // Symptom not present - no report  TODO
        }
    }
    return symptomGraphArray
}

