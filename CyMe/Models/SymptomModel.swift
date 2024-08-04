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
    var cycleOverview: [Int?]
    var hints: [String]
    var min: String
    var max: String
    var average: String
    var correlation: Float?
    var correlationOverview: [[Int?]] 
    var questionType: QuestionType 
}



