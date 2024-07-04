//
//  DiscoverViewHints.swift
//  CyMe
//
//  Created by Deborah on 27.06.2024.
//

import Foundation


/// Symptoms

func buildSymptomHints(cycleOverview : [Int?], symptomList : [DataProtocoll], dateRange: [Date], title: String, removeMaxMinHint: Bool = false) -> [String]{
    
    // Count Hint
    let count = buildSymptomCountHint(symptomList: symptomList)
    let countHint = "You have reported \(title) on \(count) days of your chosen menstrual cycle."
    
    if count == 0 { // If there are no symptoms reported we don't want many empty hints
        return [countHint]
    }
    
    
    // Quarter Frequency Analysis
    let quarter = buildSymptomQuarterFrequencyAnalysis(symptomList: symptomList, dateRange: dateRange)
    
    var quarterAnalysisHint = ""
    
    if quarter.1 == -1 { quarterAnalysisHint = ""}
    else {
        quarterAnalysisHint = "You reported \(title) most often in your \(quarter.0) quarter of your chosen menstrual cycle with  \(quarter.1) reports in total."
    }
    

    // Appetite Change does not get Max, Min hints, since there is no range - either it happens or it doesn't
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
    maxText = "The maximal severity of \(title) you reported is \(severityLabels[maxValue]!) which you reported on cycle days \(oxfordComma(list:daysWithMaxValue)). "

    
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
    minText = "The minimal severity of \(title) you reported is \(severityLabels[minValue]!) which you reported on cycle days \(oxfordComma(list:daysWithMinValue)). "
    
    return [maxText, minText]
}




/// Collected Quantities

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

func buildCollectedQuantityHint(cycleOverview : [Int?], title: String, type: availableHealthMetrics) -> [String] {
    
    var anyNonNilValues = false
    for entry in cycleOverview {
        if entry != nil{
            anyNonNilValues = true
        }
    }
    if !anyNonNilValues { return ["You don't have any \(title) data reported."]}
    
    
    // Quarter Frequency Analysis
    let quarter = buildCollectedQuantityQuarterAnalysis(cycleOverview: cycleOverview)

    var quarterAnalysisHint = ""
    if type == .sleepLength {
        quarterAnalysisHint = "You report the highest amount of \(title) in your \(quarter.0) quarter of this menstrual cycle with a total of \(SleepDataModel.formatDuration(duration : Double(quarter.1)))."
    }
    if type == .stepCount {
        quarterAnalysisHint = "You report the highest amount of \(title) in your \(quarter.0) quarter of this menstrual cycle with a total of \(quarter.1)."
    }
    if type == .exerciseTime {
        quarterAnalysisHint = "You report the highest amount of \(title) in your \(quarter.0) quarter of this menstrual cycle with a total of \(quarter.1) minutes."
    }
    
    
    
    // Max, Min over this cycle hints
    let maxValue = cycleOverview.compactMap({ $0 }).max()
    var daysWithMaxValue : [Int] = []
    for index in 0..<cycleOverview.count{
        if cycleOverview[index] == maxValue{
            daysWithMaxValue.append(index + 1)
        }
    }
    
    var maxText = ""
    if type == .sleepLength {
        maxText = "The maximal amount of \(title) you reported is \(SleepDataModel.formatDuration(duration: Double(maxValue  ?? -1))) which you reported on cycle day \(oxfordComma(list:daysWithMaxValue)). "
    }
    if type == .stepCount {
        maxText = "The maximal amount of \(title) you reported is \(maxValue ?? -1) which you reported on cycle day \(oxfordComma(list:daysWithMaxValue)). "
    }
    if type == .exerciseTime {
        maxText = "The maximal amount of \(title) you reported is \(maxValue ?? -1) minutes which you reported on cycle day \(oxfordComma(list:daysWithMaxValue)). "
    }
    
    
    
    var uniqueValues = Array(Set(cycleOverview))
    uniqueValues.removeAll { $0 == 0 }
    
    let minValue = uniqueValues.compactMap({ $0 }).min()
    var daysWithMinValue : [Int] = []
    for index in 0..<cycleOverview.count{
        if cycleOverview[index] == minValue{
            daysWithMinValue.append(index + 1)
        }
    }
    var minText = ""
    if type == .sleepLength {
        minText = "The minimal amount of \(title) you reported is \(SleepDataModel.formatDuration(duration: Double(minValue ?? -1))) which you reported on cycle day \(oxfordComma(list:daysWithMinValue)). "
    }
    if type == .stepCount {
        minText = "The minimal amount of \(title) you reported is \(minValue ?? -1) which you reported on cycle day \(oxfordComma(list:daysWithMinValue)). "
    }
    if type == .exerciseTime {
        minText = "The minimal amount of \(title) you reported is \(minValue ?? -1) minutes which you reported on cycle day \(oxfordComma(list:daysWithMinValue)). "
    }
   
    return [quarterAnalysisHint, maxText, minText]
    
}


