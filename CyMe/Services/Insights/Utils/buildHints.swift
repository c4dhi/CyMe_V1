//
//  DiscoverViewHints.swift
//  CyMe
//
//  Created by Deborah on 27.06.2024.
//

import Foundation


/// Symptoms
func buildHints(cycleOverview : [Int?], symptomList : [DataProtocoll], dateRange: [Date], title: String, removeMaxMinHint: Bool = false) -> [String]{
    
    // Count Hint
    let count = buildSymptomCountHint(symptomList: symptomList)
    let countHint = "Report-Count: \(count)"
    
    if count == 0 { // If there are no symptoms reported we don't want many empty hints
        return [countHint]
    }
    
    
    // Quarter Frequency Analysis
    let quarter = buildSymptomQuarterFrequencyAnalysis(symptomList: symptomList, dateRange: dateRange)
    
    var quarterAnalysisHint = ""
    
    if quarter.1 == -1 { quarterAnalysisHint = ""}
    else {
        quarterAnalysisHint = "Most frequently reported in: \n\(quarter.0) quarter with \(quarter.1) reports "
    }
    
    if removeMaxMinHint{
        return [countHint, quarterAnalysisHint]
    }
    
    // Max, Min over this cycle hints
    let maxMinHints = buildMinMaxHints(cycleOverview: cycleOverview, title: title)
    
    return [countHint, quarterAnalysisHint, maxMinHints[0], maxMinHints[1]]
}


func buildSymptomCountHint(symptomList : [DataProtocoll]) -> Int {
    var count = 0
    for symptom in symptomList{
        if symptom.symptomPresent{
          count += 1
        }
    }
    return count
}

func buildSymptomQuarterFrequencyAnalysis(symptomList : [DataProtocoll], dateRange: [Date]) -> (String, Int) {
    let cycleLength = dateRange.count
    let increments : Int = cycleLength/4
  
    if increments == 0 {
        return ("", -1) // We have definitely not 4 distinct quarters
    }
    
    var count_1 = 0
    for day in dateRange[0...increments-1]{
        let dailySymptomList = symptomList.filterByStartDate(startDate: day)
        for symptom in dailySymptomList{
            if symptom.symptomPresent{
                count_1 += 1
            }
        }
    }
    
    var count_2 = 0
    for day in dateRange[increments...2*increments-1]{
        let dailySymptomList = symptomList.filterByStartDate(startDate: day)
        for symptom in dailySymptomList{
            if symptom.symptomPresent{
                count_2 += 1
            }
        }
    }
    
    var count_3 = 0
    for day in dateRange[2*increments...3*increments-1]{
        let dailySymptomList = symptomList.filterByStartDate(startDate: day)
        for symptom in dailySymptomList{
            if symptom.symptomPresent{
                count_3 += 1
            }
        }
    }
    
    var count_4 = 0
    let index : Int = 3*increments
    for day in dateRange[index...]{
        let dailySymptomList = symptomList.filterByStartDate(startDate: day)
        for symptom in dailySymptomList{
            if symptom.symptomPresent{
                count_4 += 1
            }
        }
    }
   
    let maxCount = max(count_1, count_2, count_3, count_4)
    
    var output : [String] = []
    
    if count_1 == maxCount {output.append("first")}
    if count_2 == maxCount {output.append("second")}
    if count_3 == maxCount {output.append("third")}
    if count_4 == maxCount {output.append("fourth")}
    
    return (oxfordComma(list: output), maxCount)
}

func buildMinMaxHints(cycleOverview : [Int?], title: String) -> [String] { // returns [maxText, minText] in this order
    var maxText = ""
    var minText = ""
    
    
    let maxValue = cycleOverview.compactMap({ $0 }).max() ?? 0 // We will never open this function to only nil values
    
    if maxValue == 0 { return ["You have not reported \(title) in this menstrual cycle.", minText] }
    
    var daysWithMaxValue : [Int] = []
    for index in 0..<cycleOverview.count{
        if cycleOverview[index] == maxValue{
            daysWithMaxValue.append(index + 1)
        }
    }
    
    let severityLabels = [1: "mild", 2: "moderate", 3: "severe"]
    maxText = "Maximal severity: \(severityLabels[maxValue]!) \nReported on days:  \(oxfordComma(list:daysWithMaxValue)) "

    
    var uniqueSeverities = Array(Set(cycleOverview))
    uniqueSeverities.removeAll { $0 == 0 }
    uniqueSeverities.removeAll { $0 == maxValue }
    uniqueSeverities.removeAll { $0 == nil }
    
    if uniqueSeverities.isEmpty { return [maxText, minText] }
   
    let minValue = uniqueSeverities.compactMap({ $0 }).min() ?? 0 // We will never open this function to only nil values
    
    var daysWithMinValue : [Int] = []
    for index in 0..<cycleOverview.count{
        if cycleOverview[index] == minValue{
            daysWithMinValue.append(index + 1)
        }
    }
    minText = "Minimal severity: \(severityLabels[minValue]!) \nReported on days: \(oxfordComma(list:daysWithMinValue)) "
    
    return [maxText, minText]
}


/// Collected Quantities
func buildHints(cycleOverview : [Int?], title: String, type: availableHealthMetrics) -> [String] {
    
    var anyNonNilValues = false
    for entry in cycleOverview {
        if entry != nil{
            anyNonNilValues = true
        }
    }
    if !anyNonNilValues { return ["You don't have any \(title) data reported."]}
    
    
    // Quarter Frequency Analysis
    let quarter = buildCollectedQuantityQuarterAnalysis(cycleOverview: cycleOverview)

    var quarterAnalysisHint = "Highest amount of \(title): \(quarter.0) quarter"

    
    // Max, Min over this cycle hints
    let maxValue = cycleOverview.compactMap({ $0 }).max()
    var daysWithMaxValue : [Int] = []
    for index in 0..<cycleOverview.count{
        if cycleOverview[index] == maxValue{
            daysWithMaxValue.append(index + 1)
        }
    }
    
    let endingDict : [availableHealthMetrics : String] = [.stepCount : "", .sleepLength : "h", .exerciseTime : "min"]
    let ending = endingDict[type]!
    
    let maxText = "Maximum: \(maxValue ?? -1)\(ending) \nReported on day: \(oxfordComma(list:daysWithMaxValue))"
    
    
    
    
    var uniqueValues = Array(Set(cycleOverview))
    uniqueValues.removeAll { $0 == 0 }
    
    let minValue = uniqueValues.compactMap({ $0 }).min()
    var daysWithMinValue : [Int] = []
    for index in 0..<cycleOverview.count{
        if cycleOverview[index] == minValue{
            daysWithMinValue.append(index + 1)
        }
    }
    
    let minText = "Minimum: \(minValue ?? -1)\(ending) \nReported on day: \(oxfordComma(list:daysWithMinValue))"
    
    
    var sum = Float(0)
    var valuesCount = Float(0)
    
    for entry in cycleOverview{
        if entry != nil{
            sum += Float(entry ?? 0)
            valuesCount += 1
        }
    }
    
    let average = sum/valuesCount
    let averageText = "Average: \(String(format: "%.2f", average))\(ending)"

    return [quarterAnalysisHint, maxText, minText, averageText]
    
}


func buildCollectedQuantityQuarterAnalysis (cycleOverview: [Int?]) -> (String, Int){
    let cycleLength = cycleOverview.count
    let increments : Int = cycleLength/4
    
    if increments == 0 {
        return ("", -1) // We have definitely not 4 distinct quarters
    }
    
    var count_1 = 0
    for amount in cycleOverview[0...increments-1]{
        count_1 += amount ?? 0
    }
    
    var count_2 = 0
    for amount in cycleOverview[increments...2*increments-1]{
        count_2 += amount ?? 0
    }
    
    var count_3 = 0
    for amount in cycleOverview[2*increments...3*increments-1]{
        count_3 += amount ?? 0
    }
    
    var count_4 = 0
    let index : Int = 3*increments
    for amount in cycleOverview[index...]{
        count_4 += amount ?? 0
    }
    
    let maxCount = max(count_1, count_2, count_3, count_4)
    
    var output : [String] = []
    
    if count_1 == maxCount {output.append("first")}
    if count_2 == maxCount {output.append("second")}
    if count_3 == maxCount {output.append("third")}
    if count_4 == maxCount {output.append("fourth")}
    
    return (oxfordComma(list: output), maxCount)
    
}



