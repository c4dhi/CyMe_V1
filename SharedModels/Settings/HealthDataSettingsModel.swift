//
//  HealthDataSettingsModel.swift
//  CyMe
//
//  Created by Marinja Principe on 29.05.24.
//

import Foundation

import Foundation


enum DataLocation: String, Codable {
    case sync = "sync"
    case onlyCyMe = "onlyCyMe"
    case onlyAppleHealth = "onlyAppleHealth"
}


enum QuestionType: String,  Codable {
    case emoticonRating = "emoticonRating"
    case menstruationEmoticonRating = "menstruationEmoticonRating"
    case menstruationStartRating = "menstruationStartRating"
    case painEmoticonRating = "painEmoticonRating"
    case changeEmoticonRating = "changeEmoticonRating"
    case amountOfhour = "amountOfhour"
    case amountOfSteps = "amountOfSteps"
    case open = "open"
}

struct HealthDataSettingsModel: Identifiable, Codable {
    var name: String
    var label: String
    var enableDataSync: Bool
    var enableSelfReportingCyMe: Bool
    let dataLocation: DataLocation
    var question: String?
    var questionType: QuestionType?
    
    var id: String { name }
}
