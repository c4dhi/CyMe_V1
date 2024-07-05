//
//  DiscoverViewStatistics.swift
//  CyMe
//
//  Created by Deborah on 27.06.2024.
//

import Foundation

/// Symptoms

func buildSymptomMinMaxAverage(symptomListCurrent: [DataProtocoll], symptomListLast : [DataProtocoll], symptomListSecondToLast : [DataProtocoll], title : String, availableCycles : Int) -> [String]{
    
    if availableCycles < 2 {
        return ["You need at least two cycles to compare them.", "", ""]
    }
    
    let countCurrent = buildSymptomCountHint(symptomList: symptomListCurrent)
    let countLast = buildSymptomCountHint(symptomList: symptomListLast)
    var countSecondToLast = buildSymptomCountHint(symptomList: symptomListSecondToLast)
    
    if availableCycles == 2 { //meaning we don't have secondToLast available
        countSecondToLast = countLast
    }
    
    let max = [countCurrent, countLast, countSecondToLast].max()
    let min = [countCurrent, countLast, countSecondToLast].min()
    
    if max == min {
        return ["In all considered cycles you have reported the same amount of \(title) which is \( max!). (Up to the last three stared cycles considered)", "", ""]
    }
    
    var maxList : [String] = []
    var minList : [String] = []
    
    if countCurrent == max { maxList.append("current") }
    if countCurrent == min { minList.append("current") }
    
    if countLast == max { maxList.append("last") }
    if countLast == min { minList.append("last") }
    
    if availableCycles > 2{
        if countSecondToLast == max { maxList.append("second to last") }
        if countSecondToLast == min { minList.append("second to last") }
    }
    
    let maxText = "You have reported the maximal amount of \(title) in your \(oxfordComma(list: maxList)) menstrual cycle, with \(String(max!)) reports in these cycles."
    let minText = "You have reported the minimal amount of \(title) in your \(oxfordComma(list: minList)) menstrual cycle, with \( String(min!)) reports in these cycles."
    
    if availableCycles == 2{
        let average = Double(countCurrent + countLast)/2
        let averageText = "You have reported \(title) on average \(String(format: "%.2f", average)) times per cycle (in your last two cycles)."
        return [minText, maxText, averageText]
    }
    else {
        let average = Double(countCurrent + countLast + countSecondToLast)/3
        let averageText = "You have reported \(title) on average \(String(format: "%.2f", average)) times per cycle (in your last three cycles)."
        return [minText, maxText, averageText]
    }
}


/// Collected Quantities

func buildCollectedQuantityMinMaxAverage(cycleOverviewCurrent: [Int?], cycleOverviewLast : [Int?], cycleOverviewSecondToLast : [Int?], availableCycles : Int, title: String, type: availableHealthMetrics ) -> [String]{
    
    if availableCycles < 2 {
        return ["You need at least two cycles to compare them.", "", ""]
    }
    
    let sumCurrent =  cycleOverviewCurrent.compactMap { $0 }.reduce(0, +)
    let sumLast = cycleOverviewLast.compactMap { $0 }.reduce(0, +)
    var sumSecondToLast : Int
    
    if availableCycles == 2 { //meaning we don't have secondToLast available
        sumSecondToLast = sumLast
    }
    else{
        sumSecondToLast = cycleOverviewSecondToLast.compactMap { $0 }.reduce(0, +)
    }
    
    let max = [sumCurrent, sumLast, sumSecondToLast].max()
    let min = [sumCurrent, sumLast, sumSecondToLast].min()
    
    if max == min {
        return ["In all considered cycles you have reported the same sum of \(title) which is \( max!). (Up to the last three stared cycles considered)", "", ""]
    }
    
    var maxList : [String] = []
    var minList : [String] = []
    
    if sumCurrent == max { maxList.append("current") }
    if sumCurrent == min { minList.append("current") }
    
    if sumLast == max { maxList.append("last") }
    if sumLast == min { minList.append("last") }
    
    if availableCycles > 2{
        if sumSecondToLast == max { maxList.append("second to last") }
        if sumSecondToLast == min { minList.append("second to last") }
    }
    
    var endOfMaxText = ""
    var endOfMinText = ""
    
    if type == .sleepLength {
        endOfMaxText = "\(SleepDataModel.formatDuration(duration: Double(max!))) of sleep."
        endOfMinText = "\(SleepDataModel.formatDuration(duration: Double(min!))) of sleep."
    }
    if type == .stepCount {
        endOfMaxText = "\(String(max!)) steps."
        endOfMinText = "\(String(min!)) steps."
    }
    if type == .exerciseTime {
        endOfMaxText = "\(String(max!)) minutes."
        endOfMinText = "\(String(min!)) minutes."
    }
    
    let maxText = "You have reported the maximal sum of \(title) in your \(oxfordComma(list: maxList)) menstrual cycle, with a total of \(endOfMaxText)"
    let minText = "You have reported the minimal sum of \(title) in your \(oxfordComma(list: minList)) menstrual cycle, with a total of \(endOfMinText)"
    
    
    var average : Double
    var consideredCycles : String
    var averageText = ""
    
    if availableCycles == 2 {
        average = Double(sumCurrent + sumLast)/2
        consideredCycles = "two"
    }
    else{
        average = Double(sumCurrent + sumLast + sumSecondToLast)/3
        consideredCycles = "three"
    }
    
    
    if type == .sleepLength {
        averageText = "On average you have a sum of \(SleepDataModel.formatDuration(duration: average)) over the last \(consideredCycles) cycles"
        
    }
    if type == .stepCount {
        averageText = "On average you have a sum of \(String(format: "%.2f", average)) steps over the last \(consideredCycles) cycles"
    }
    if type == .exerciseTime {
        averageText = "On average you have a sum of \(String(format: "%.2f", average)) exercise minutes over the last \(consideredCycles) cycles"
    }
   
    return [minText, maxText, averageText]
    
}

/// BOTH

func buildCovariance(cycleOverviewCurrent: [Int?], cycleOverviewLast : [Int?], cycleOverviewSecondToLast : [Int?], cyclesAvailable : Int ) -> (Float, [[Int?]]) {
    
    if cyclesAvailable < 2 {
        print( "You need at least two cycles that are started to compute the covariance.")
        return (-1, [[]])
    }
    
    var list1 : [Int?]
    var list2 : [Int?]
    
    
    
    if cyclesAvailable == 2 { //Second to Last is not available
        list1 = cycleOverviewCurrent
        list2 = cycleOverviewLast
    }
    else {
        list1 = cycleOverviewSecondToLast
        list2 = cycleOverviewLast
    }
    
    var averageSum1 = 0
    var averageSum2 = 0
    
    // Compute averages
    for entry in list1{
        if entry != nil {
            averageSum1 += entry!
        }
    }
    // TODO if we skip the tail, should we then consider the average only up to the tail?
    for entry in list2{
        if entry != nil {
            averageSum2 += entry!
        }
    }
    
    let average1 = Float(averageSum1)/Float(list1.count)
    let average2 = Float(averageSum2)/Float(list2.count)
    
    var sum = Float(0)
    
    let largerIndex = max(list1.count, list2.count)
    let smallerIndex = min(list1.count, list2.count)

    for i in (0..<largerIndex){
        if i<smallerIndex{
            let entry1 = Float((list1[i] ?? 0))
            let entry2 = Float((list2[i] ?? 0))
            sum += (entry1 - average1)*(entry2 - average2) // NIL is mapped onto 0
            //sum += (list1[i]? - average1)*(list2[i]? - average2) // NIL is skipped
        }
        // do nothing - Tail is skipped - non-existant differences are 0
        // implement - Tail is considered as variance - non-existant differences are 1
    }

    let covariance = Float(sum)/Float(smallerIndex)

    return (covariance, [Array(list1[0..<smallerIndex]), Array(list2[0..<smallerIndex])])
}

