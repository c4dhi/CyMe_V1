//
//  SelfReportModel.swift
//  CyMe
//
//  Created by Marinja Principe on 06.05.24.
//

import Foundation

enum selfReportMediumType: String,  Codable {
    case iOSApp = "iOSApp"
    case watchApp = "watchApp"
    case widget = "widget"
    case appleHealth = "painEmotappleHealthiconRating"
}

struct SelfReportModel: Codable, Identifiable {
    var id: Int?
    var startTime: Date
    var endTime: Date
    var isCyMeSelfReport: Bool
    var selfReportMedium: selfReportMediumType
    var reports: [SymptomSelfReportModel]
    
}

struct SymptomSelfReportModel: Codable {
    let healthDataName: String
    let healthDataLabel: String
    let questionType: QuestionType
    var reportedValue: String?
}
