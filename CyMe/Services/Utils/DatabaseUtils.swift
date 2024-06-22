//
//  DatabaseUtils.swift
//  CyMe
//
//  Created by Marinja Principe on 27.05.24.
//

import Foundation

// translate string

func stringToUTF8(_ string: String?) -> UnsafePointer<Int8>? {
    guard let string = string else {
        return nil
    }
    
    return (string as NSString).utf8String
}



// translate bool
func boolToNSStringUTF8String(_ value: Bool) -> UnsafePointer<Int8>? {
    return (value ? "true" : "false" as NSString).utf8String
}
func stringToBool(_ value: String) -> Bool {
    return value.lowercased() == "true"
}

// translate models
func modelToJSONStringUTF8<T: Codable>(_ model: T) -> UnsafePointer<Int8>? {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601 // Handle Date encoding properly
    if let jsonData = try? encoder.encode(model) {
        return (String(data: jsonData, encoding: .utf8) as NSString?)?.utf8String
    }
    return nil
}

func jsonStringToModel<T: Codable>(_ jsonString: UnsafePointer<Int8>, modelType: T.Type) -> T? {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601 // Handle Date decoding properly
    if let jsonData = String(cString: jsonString).data(using: .utf8) {
        return try? decoder.decode(T.self, from: jsonData)
    }
    return nil
}

// translate date
func dateToStringUTF8(_ date: Date) -> UnsafePointer<Int8>? {
    let dateFormatter = ISO8601DateFormatter()
    let dateString = dateFormatter.string(from: date)
    return (dateString as NSString).utf8String
}


func stringToDate(_ dateString: String) -> Date? {
    let dateFormatter = ISO8601DateFormatter()
    return dateFormatter.date(from: dateString)
}



// translate datalocation
func stringToDataLocation(_ string: String) -> DataLocation? {
    return DataLocation(rawValue: string)
}

// Translate DataLocation
func dataLocationToUTF8String(_ dataLocation: DataLocation) -> UnsafePointer<Int8>? {
    return (dataLocation.rawValue as NSString).utf8String
}

func questionTypeToUTF8String(_ questionType: QuestionType?) -> UnsafePointer<Int8>? {
    return (questionType?.rawValue as NSString?)?.utf8String
}


// translate reminderModel
func encodeReminderModel(_ reminder: ReminderModel) -> String {
    do {
        let jsonData = try JSONEncoder().encode(reminder)
        return String(data: jsonData, encoding: .utf8) ?? ""
    } catch {
        print("Failed to encode reminder model: \(error)")
        return ""
    }
}

func decodeReminderModel(from data: Data) -> ReminderModel {
    do {
        return try JSONDecoder().decode(ReminderModel.self, from: data)
    } catch {
        print("Failed to decode reminder model: \(error)")
        return ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date())
    }
}

func decodeDataLocation(datalocationString: String) -> DataLocation? {
    return DataLocation(rawValue: datalocationString)
}

func decodeQuestionType(questionTypeString: String) -> QuestionType? {
    return QuestionType(rawValue: questionTypeString)
}



