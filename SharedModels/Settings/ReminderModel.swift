//
//  ReminderModel.swift
//  CyMe
//
//  Created by Marinja Principe on 22.05.24.
//

import Foundation

struct ReminderModel: Codable {
    var isEnabled: Bool
    var frequency: String
    var times: [Date]
    var startDate: Date
    
    enum CodingKeys: String, CodingKey {
        case isEnabled
        case frequency
        case times
        case startDate
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    init(isEnabled: Bool, frequency: String, times: [Date], startDate: Date) {
        self.isEnabled = isEnabled
        self.frequency = frequency
        self.times = times
        self.startDate = startDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        self.frequency = try container.decode(String.self, forKey: .frequency)
        let timesString = try container.decode([String].self, forKey: .times)
        self.times = timesString.map { ReminderModel.dateFormatter.date(from: $0)! }
        let startDateString = try container.decode(String.self, forKey: .startDate)
        self.startDate = ReminderModel.dateFormatter.date(from: startDateString)!
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(frequency, forKey: .frequency)
        let timesString = times.map { ReminderModel.dateFormatter.string(from: $0) }
        try container.encode(timesString, forKey: .times)
        let startDateString = ReminderModel.dateFormatter.string(from: startDate)
        try container.encode(startDateString, forKey: .startDate)
    }
}
