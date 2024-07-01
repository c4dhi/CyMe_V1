//
//  DbService.swift
//  CyMe
//
//  Created by Marinja Principe on 22.04.24.
//

// DatabaseService.swift
// CyMe

import Foundation
import SQLite3

class DatabaseService {
    static let shared: DatabaseService = DatabaseService()
    
    internal var db: OpaquePointer?
    
    lazy var settingsService: SettingsDatabaseService = {
        return SettingsDatabaseService()
    }()
    
    lazy var userDatabaseService: UserDatabaseService = {
        return UserDatabaseService()
    }()
    
    lazy var reportingDatabaseService: ReportingDatabaseService = {
        return ReportingDatabaseService()
    }()

    private init() {
        self.db = self.openDatabase()
    }

    private func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("CyMe.sqlite")

        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return nil
        } else {
            print("Successfully opened connection to database at \(fileURL.path)")
            return db
        }
    }
    
    func executeQuery(_ query: String) -> Bool {
        var statement: OpaquePointer?
        defer { sqlite3_finalize(statement) }
        
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            if let error = sqlite3_errmsg(db) {
                print("Error preparing statement: \(String(cString: error))")
            }
            return false
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            return true
        } else {
            if let error = sqlite3_errmsg(db) {
                print("Error executing query: \(String(cString: error))")
            }
            return false
        }
    }
    
    func getDatabasePointer() -> OpaquePointer? {
        return db
    }
}
