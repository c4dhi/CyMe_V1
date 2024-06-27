//
//  DiscoverViewHints.swift
//  CyMe
//
//  Created by Deborah on 27.06.2024.
//

import Foundation



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


func buildSymptomHints(cycleOverview : [Int], symptomList : [DataProtocoll], dateRange: [Date], title: String) -> [String]{
    
    // Count Hint
    let count = buildSymptomCountHint(symptomList: symptomList)
    let countHint = "You have reported \(title) on \(count) days of your last cycle."
    
    if count == 0 { // If there are no symptoms reported we don't want many empty hints
        return [countHint]
    }
    
    
    // Quarter Frequency Analysis
    let quarter = buildSymptomQuarterFrequencyAnalysis(symptomList: symptomList, dateRange: dateRange)

    let quarterAnalysisHint = "You reported \(title) most often in your \(quarter.0) quarter of this menstrual cycle with \(quarter.1) reports in total."

    return [countHint, quarterAnalysisHint]
}

func buildCollectedQuantityHint(cycleOverview : [Int], title: String) -> [String] {
    
    // Quarter Frequency Analysis
    
    let cycleLength = cycleOverview.count
    let increments : Int = cycleLength/4
    
    var frequency_1 = 0
    for day in cycleOverview[0...increments-1]{
        if day != 0 { frequency_1 += 1 }
    }
    
    var frequency_2 = 0
    for day in cycleOverview[increments...2*increments-1]{
        if day != 0 { frequency_2 += 1 }
    }
    
    var frequency_3 = 0
    for day in cycleOverview[2*increments...3*increments-1]{
        if day != 0 { frequency_3 += 1 }
    }
    
    var frequency_4 = 0
    let index : Int = 3*increments
    for day in cycleOverview[index...]{
        if day != 0 { frequency_4 += 1 }
    }
    
    let frequencyDict = ["first": frequency_1, "second": frequency_2, "third": frequency_3, "fourth": frequency_4,]
    let highestFrequencyQuarter = frequencyDict.max(by: { a, b in a.value < b.value })!

    
    let quarterAnalysisHint = "You reported \(title) most often in your \(highestFrequencyQuarter.key) quarter of this menstrual cycle with \(highestFrequencyQuarter.value) reports in total."
    
    return [quarterAnalysisHint]
    
    
}


func buildMinMaxHints(cycleOverview : [Int], title: String) -> [String] { // returns [maxText, minText] in this order
    var maxText = ""
    var minText = ""
    
    let maxValue = cycleOverview.max()
    
    if maxValue == 0 { return ["You have not reported \(title) in this menstrual cycle.", minText] }
    
    var daysWithMaxValue : [Int] = []
    for index in 0..<cycleOverview.count{
        if cycleOverview[index] == maxValue{
            daysWithMaxValue.append(index + 1)
        }
    }
    
    let severityLabels = [1: "mild", 2: "moderate", 3: "severe"]
    maxText = "The maximal severity of \(title) you reported is \(severityLabels[maxValue!]!) which you reported on cycle days \(oxfordComma(list:daysWithMaxValue)). "

    
    var uniqueSeverities = Array(Set(cycleOverview))
    uniqueSeverities.removeAll { $0 == 0 }
    uniqueSeverities.removeAll { $0 == maxValue }
    
    if uniqueSeverities.isEmpty { return [maxText, minText] }
   
    let minValue = uniqueSeverities.min()
    
    
    var daysWithMinValue : [Int] = []
    for index in 0..<cycleOverview.count{
        if cycleOverview[index] == minValue{
            daysWithMinValue.append(index + 1)
        }
    }
    minText = "The minimal severity of \(title) you reported is \(severityLabels[minValue!]!) which you reported on cycle days \(oxfordComma(list:daysWithMinValue)). "
    
    return [maxText, minText]
}
