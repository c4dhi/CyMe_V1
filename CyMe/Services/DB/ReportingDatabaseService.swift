//
//  ReportingDatabaseService.swift
//  CyMe
//
//  Created by Marinja Principe on 25.05.24.
//

import Foundation

class ReportingDatabaseService {
    static let shared = UserDatabaseService()
    private var db: OpaquePointer?
    
    init() {
        db = DatabaseService.shared.db
    }
}
