//
//  HealthDataSettingsModel.swift
//  CyMe
//
//  Created by Marinja Principe on 29.05.24.
//

import Foundation

import Foundation


enum DataLocation: String {
    case sync = "sync"
    case onlyCyMe = "onlyCyMe"
    case onlyAppleHealth = "onlyAppleHealth"
}


enum QuestionType: String,  Codable {
    case intensity = "intensity"
    case emoticonRating = "emoticonRating"
    case menstruationEmoticonRating = "menstruationEmoticonRating"
    case painEmoticonRating = "painEmoticonRating"
    case amountOfhour = "amountOfhour"
    case open = "open"
}

struct HealthDataSettingsModel: Identifiable {
    var title: String
    var enableDataSync: Bool
    var enableSelfReportingCyMe: Bool
    let dataLocation: DataLocation
    var question: String?
    var questionType: QuestionType?
    
    var id: String { title }
}
