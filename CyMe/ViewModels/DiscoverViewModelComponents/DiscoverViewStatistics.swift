//
//  DiscoverViewStatistics.swift
//  CyMe
//
//  Created by Deborah on 27.06.2024.
//

import Foundation


/// Symptoms
///
func buildSymptomMinMaxAverage(symptomList: [DataProtocoll], dateRange: [Date]) -> [String]{
    
    return ["Min", "Max", "Average"]
}

func buildSymptomCovariance(symptomList: [DataProtocoll], dateRange: [Date]) -> Float {
    
    return 0.0
}

/// Collected Quantities

func buildCollectedQuantityMinMaxAverage(symptomList: [Date : any Numeric & Comparable], dateRange: [Date]) -> [String]{
    
    return ["Min", "Max", "Average"]
}

func buildCollectedQuantityCovariance(symptomList: [Date : any Numeric & Comparable], dateRange: [Date]) -> Float {
    
    return 0.0
}
