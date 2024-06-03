//
//  SelfReportModel.swift
//  CyMe
//
//  Created by Marinja Principe on 06.05.24.
//

import Foundation

struct SelfReportModel: Codable {
    let healthDataTitle: String
    let questionType: QuestionType
    var reportedValue: String
}
