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


struct HealthDataSettingsModel: Identifiable {
    let title: String
    var enableDataSync: Bool
    var enableSelfReportingCyMe: Bool
    let dataLocation: DataLocation
    
    var id: String { title }
}
