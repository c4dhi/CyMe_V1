//
//  DiscoverViewStatistics.swift
//  CyMe
//
//  Created by Deborah on 27.06.2024.
//

import Foundation

/// Symptoms
func buildMinMaxAverage(symptomListCurrent: [DataProtocoll], symptomListLast : [DataProtocoll], symptomListSecondToLast : [DataProtocoll], title : String, availableCycles : Int) -> [String]{
    
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
    
    let maxText = "Maximum over cycles: \(oxfordComma(list: maxList)) cycle \nWith \(String(max!)) reports \n"
    let minText = "Minimum over cycles: \(oxfordComma(list: minList)) cycle \nWith \( String(min!)) reports \n"
    
    var averageText = ""
    if availableCycles == 2 {
        let average = Double(countCurrent + countLast)/2
        averageText = "Average: \(String(format: "%.2f", average)) reports per cycle"
    }
    else {
        let average = Double(countCurrent + countLast + countSecondToLast)/3
        averageText = "Average: \(String(format: "%.2f", average)) reports per cycle"
    }
    return [minText, maxText, averageText]
}


/// Collected Quantities
func buildMinMaxAverage(cycleOverviewCurrent: [Int?], cycleOverviewLast : [Int?], cycleOverviewSecondToLast : [Int?], title: String, availableCycles : Int,  type: availableHealthMetrics ) -> [String]{
    
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
    
    let maxText = "Maximal sum over cycles: \(oxfordComma(list: maxList)) cycle\n"
    let minText = "Minimal sum over cycles: \(oxfordComma(list: minList)) cycle\n"

   
    return [minText, maxText, ""]
    
}

/// BOTH

func buildCorrelation(cycleOverviewCurrent: [Int?], cycleOverviewLast : [Int?], cycleOverviewSecondToLast : [Int?], cyclesAvailable : Int ) -> (Float?, [[Int?]]) {
    
    if cyclesAvailable < 2 {
        print( "You need at least two cycles that are started to compute the correlation.")
        return (nil, [[nil], [nil]])
    }
    
    var list1 : [Int?]
    var list2 : [Int?]
    
    
    
    if cyclesAvailable == 2 { //Second to Last is not available
        list1 = cycleOverviewCurrent
        list2 = cycleOverviewLast
    }
    else {
        list1 = cycleOverviewLast
        list2 = cycleOverviewSecondToLast
    }
    
    var averageSum1 = 0
    var averageSum2 = 0
    
    // Compute averages
    for entry in list1{
        if entry != nil {
            averageSum1 += entry!
        }
    }
    // Possible Choice: if we skip the tail, should we then consider the average only up to the tail?
    for entry in list2{
        if entry != nil {
            averageSum2 += entry!
        }
    }
    
    let average1 = Float(averageSum1)/Float(list1.count)
    let average2 = Float(averageSum2)/Float(list2.count)
    
    let largerIndex = max(list1.count, list2.count)
    let smallerIndex = min(list1.count, list2.count)
    
    // calculation of correlation https://zief0002.github.io/matrix-algebra/statistical-application-vectors.html
    
    var lxSum  = Float(0)
    var lySum  = Float(0)
    
    var covarianceSum = Float(0)
    
    for i in (0..<largerIndex){
        if i<smallerIndex{
    
            let entry1 = Float((list1[i] ?? 0)) - average1
            let entry2 = Float((list2[i] ?? 0)) - average2
                        
            lxSum += entry1*entry1
            lySum += entry2*entry2
        
           
            covarianceSum += entry1*entry2 // NIL is mapped onto 0
        }
        // do nothing - Tail is skipped - non-existant differences are 0 - Possible Choices exist
    }

    let covariance = Float(covarianceSum)/Float(smallerIndex)
    let sx = sqrt(lxSum)/sqrt(Float(smallerIndex))
    let sy = sqrt(lySum)/sqrt(Float(smallerIndex))
    
    if sx*sy == 0{
        return(nil, [Array(list1[0..<smallerIndex]), Array(list2[0..<smallerIndex])])
    }
    
    let correlation = covariance/(sx * sy)

    return (correlation, [Array(list1[0..<smallerIndex]), Array(list2[0..<smallerIndex])])
}

