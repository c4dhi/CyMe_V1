//
//  DbService.swift
//  CyMe
//
//  Created by Marinja Principe on 22.04.24.
//

import Foundation
import SQLite3

class DatabaseService {
    static let shared = DatabaseService()
    
    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createHealthDataTable()
        createUserTableIfNeeded()
    }

    private func openDatabase() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to access documents directory")
            return
        }
        
        let dbPath = documentsPath.appendingPathComponent("CyMe.sqlite").path
        
        // Check if the database file exists
        if !FileManager.default.fileExists(atPath: dbPath) {
            // If the database file does not exist, create it
            if sqlite3_open(dbPath, &db) == SQLITE_OK {
                print("Successfully created and opened connection to database at \(dbPath)")
            } else {
                print("Unable to create and open database.")
            }
        } else {
            // If the database file already exists, open it
            if sqlite3_open(dbPath, &db) == SQLITE_OK {
                print("Successfully opened connection to existing database at \(dbPath)")
            } else {
                print("Unable to open existing database.")
            }
        }
    }

    private func createHealthDataTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS health_data (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                utcSeconds TEXT,
                steps TEXT
            );
            """
        
        if executeQuery(createTableQuery) {
            print("Health_data table created successfully or already exists")
        } else {
            print("Error creating Health_data table")
        }
    }
    
    // Create, Get and Adjust user table
    private func createUserTableIfNeeded() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS user (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                age INTEGER,
                lifePhase TEXT,
                regularCycle TEXT,
                contraceptions TEXT,
                fertilityGoal TEXT
            );
            """
        
        if executeQuery(createTableQuery) {
            print("User table created successfully or already exists")
        } else {
            print("Error creating user table")
        }
    }
    
    func insertUser(name: String, age: Int, lifePhase: String, regularCycle: String, contraceptions: String, fertilityGoal: String) -> Bool {
        let insertQuery = """
            INSERT INTO user (name, age, lifePhase, regularCycle, contraceptions, fertilityGoal)
            VALUES (?, ?, ?, ?, ?, ?);
            """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing insert statement")
            return false
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement, 2, Int32(age))
        sqlite3_bind_text(statement, 3, (lifePhase as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (regularCycle as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 5, (contraceptions as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 6, (fertilityGoal as NSString).utf8String, -1, nil)
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Successfully inserted user")
            return true
        } else {
            if let error = sqlite3_errmsg(db) {
                print("Failed to insert user: \(String(cString: error))")
            }
            return false
        }
    }
    
    // Create, Get and Adjust settings table
    private func createSettingsTableIfNeeded() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS settings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                enableHealthKit TEXT,
                connectWatch TEXT,
                enableSleepQualityMeasuring TEXT,
                enableSleepQualitySelfReporting TEXT,
                enableMenstrualCycleLengthMeasuring TEXT,
                enableMenstrualCycleLengthReporting TEXT,
                enableHeartRateMeasuring TEXT,
                enableHeartRateReporting TEXT,
                selfReportingReminder TEXT,
                dailySummaryReminder TEXT,
                startPeriodReminder TEXT,
                enableSelfReportingOnWatch TEXT,
                primaryColor TEXT,
                secondaryColor TEXT,
                tertiaryColor TEXT,
                enableWidgets TEXT
            );
            """
        
        if executeQuery(createTableQuery) {
            print("Settings table created successfully or already exists")
        } else {
            print("Error creating settings table")
        }
    }
    
    func insertSettings(enableHealthKit: String, connectWatch: String, enableSleepQualityMeasuring: String, enableSleepQualitySelfReporting: String, enableMenstrualCycleLengthMeasuring: String, enableMenstrualCycleLengthReporting: String, enableHeartRateMeasuring: String, enableHeartRateReporting: String, selfReportingReminder: String, dailySummaryReminder: String, startPeriodReminder: String, enableSelfReportingOnWatch: String, primaryColor: String, secondaryColor: String, tertiaryColor: String, enableWidgets: String) -> Bool {
        let insertQuery = """
            INSERT INTO settings (enableHealthKit, connectWatch, enableSleepQualityMeasuring, enableSleepQualitySelfReporting, enableMenstrualCycleLengthMeasuring, enableMenstrualCycleLengthReporting, enableHeartRateMeasuring, enableHeartRateReporting, selfReportingReminder, dailySummaryReminder, startPeriodReminder, enableSelfReportingOnWatch, primaryColor, secondaryColor, tertiaryColor, enableWidgets)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
            """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing insert statement")
            return false
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        sqlite3_bind_text(statement, 1, (enableHealthKit as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (connectWatch as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (enableSleepQualityMeasuring as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (enableSleepQualitySelfReporting as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 5, (enableMenstrualCycleLengthMeasuring as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 6, (enableMenstrualCycleLengthReporting as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 7, (enableHeartRateMeasuring as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 8, (enableHeartRateReporting as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 9, (selfReportingReminder as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 10, (dailySummaryReminder as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 11, (startPeriodReminder as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 12, (enableSelfReportingOnWatch as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 13, (primaryColor as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 14, (secondaryColor as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 15, (tertiaryColor as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 16, (enableWidgets as NSString).utf8String, -1, nil)
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Successfully inserted settings")
            return true
        } else {
            if let error = sqlite3_errmsg(db) {
                print("Failed to insert settings: \(String(cString: error))")
            }
            return false
        }
    }

    
    func getUserName() -> String? {
        let query = "SELECT name FROM user LIMIT 1;"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing query")
            return nil
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_ROW else {
            print("No rows found")
            return nil
        }
        
        guard let namePtr = sqlite3_column_text(statement, 0) else {
            print("No name found")
            return nil
        }
        
        return String(cString: namePtr)
    }
    
    private func executeQuery(_ query: String) -> Bool {
        var errorMessage: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, query, nil, nil, &errorMessage) != SQLITE_OK {
            if let error = errorMessage {
                print("Error executing query: \(String(cString: error))")
                sqlite3_free(error)
            }
            return false
        }
        return true
    }
}
