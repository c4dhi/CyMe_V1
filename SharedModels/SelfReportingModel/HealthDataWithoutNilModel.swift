//
//  HealthDataWithoutNilModel.swift
//  CyMe
//
//  Created by Marinja Principe on 02.06.24.
//

import Foundation


struct HealthDataWithoutNilModel: Identifiable {
    var title: String
    var enableDataSync: Bool
    var enableSelfReportingCyMe: Bool
    var dataLocation: DataLocation
    var question: String
    var questionType: QuestionType
    
    var id: String { title }
}
