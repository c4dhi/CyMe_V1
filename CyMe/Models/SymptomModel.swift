//
//  DiscoverModel.swift
//  CyMe
//
//  Created by Marinja Principe on 03.06.24.
//

import Foundation

struct SymptomModel: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var dateRange : [Date]
    var cycleOverview: [Int]
    var hints: [String]
    var min: Int // Da fändi wahrschinlich String besser weu je nach Symptom macht nid aues glich sinn (und me chönnt s Datum o grad dri due, süsch müesst me wahrschinlich mega afo ungerscheide im Frontend...
    var max: Int // Same
    var average: Int // Same
    var covariance: Float
    var covarianceOverview: [[Int]] 
    var questionType: QuestionType 
}



