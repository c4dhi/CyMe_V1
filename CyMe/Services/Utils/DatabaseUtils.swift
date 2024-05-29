//
//  DatabaseUtils.swift
//  CyMe
//
//  Created by Marinja Principe on 27.05.24.
//

import Foundation

func boolToNSStringUTF8String(_ value: Bool) -> UnsafePointer<Int8>? {
    return (value ? "true" : "false" as NSString).utf8String
}
func stringToBool(_ value: String) -> Bool {
    return value.lowercased() == "true"
}

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

func stringToDataLocation(_ string: String) -> DataLocation? {
    return DataLocation(rawValue: string)
}




