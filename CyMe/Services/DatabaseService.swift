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
                utcSeconds TEXT
                steps TEXT
            );
            """
        
        if executeQuery(createTableQuery) {
            print("Health_data table created successfully or already exists")
        } else {
            print("Error creating Health_data table")
        }
    }
    
    private func createUserTableIfNeeded() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS user (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT
            );
            """
        
        if executeQuery(createTableQuery) {
            print("User table created successfully or already exists")
        } else {
            print("Error creating user table")
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
