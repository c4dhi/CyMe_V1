// UserDatabaseService.swift
// CyMe

import Foundation
import SQLite3

class UserDatabaseService {
    private var db: OpaquePointer?

    init() {
        self.db = DatabaseService.shared.db
        createUserTableIfNeeded()
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
            
            if DatabaseService.shared.executeQuery(createTableQuery) {
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
        
        func saveUser(user: UserModel) {
            let fetchQuery = "SELECT COUNT(*) FROM user WHERE id = 1;"
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, fetchQuery, -1, &statement, nil) == SQLITE_OK else {
                print("Error preparing fetch statement")
                return
            }

            defer { sqlite3_finalize(statement) }

            var count: Int32 = 0
            if sqlite3_step(statement) == SQLITE_ROW {
                count = sqlite3_column_int(statement, 0)
            }

            if count > 0 {
                updateUser(user: user)
            } else {
                insertUser(user: user)
            }
        }
        
        func loadUser() -> UserModel {
            let selectQuery = "SELECT * FROM user WHERE id = 1;"
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, selectQuery, -1, &statement, nil) == SQLITE_OK else {
                print("Error preparing select statement")
                return defaultUser()
            }

            defer { sqlite3_finalize(statement) }

            if sqlite3_step(statement) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(statement, 1))
                let age = Int(sqlite3_column_int(statement, 2))
                let lifePhase = String(cString: sqlite3_column_text(statement, 3))
                let regularCycle = sqlite3_column_int(statement, 4) == 1
                let cycleLength = Int(sqlite3_column_int(statement, 5))
                let contraceptionsString = String(cString: sqlite3_column_text(statement, 5))
                let contraceptions = contraceptionsString.split(separator: ",").map { String($0) }
                let fertilityGoal = String(cString: sqlite3_column_text(statement, 6))

                return UserModel(name: name, age: age, lifePhase: lifePhase, regularCycle: regularCycle, cycleLength: cycleLength, contraceptions: contraceptions, fertilityGoal: fertilityGoal)
            } else {
                return defaultUser()
            }
        }

        func defaultUser() -> UserModel {
            return UserModel(name: "", age: 0, lifePhase: "Premenopause", regularCycle: false, cycleLength: 28, contraceptions: [], fertilityGoal: "Avoiding pregnancy")
        }


        private func insertUser(user: UserModel) -> Bool {
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
            
            let contraceptionsString = user.contraceptions.joined(separator: ",")
            
            sqlite3_bind_text(statement, 1, (user.name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(user.age))
            sqlite3_bind_text(statement, 3, (user.lifePhase as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (user.regularCycle ? "true" : "false" as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 5, Int32(user.cycleLength))
            sqlite3_bind_text(statement, 5, (contraceptionsString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 6, (user.fertilityGoal as NSString).utf8String, -1, nil)
            
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

        private func updateUser(user: UserModel) -> Bool {
            let updateQuery = """
                UPDATE user SET
                    name = ?, age = ?, lifePhase = ?, regularCycle = ?,
                    contraceptions = ?, fertilityGoal = ?
                WHERE id = 1;
                """

            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, updateQuery, -1, &statement, nil) == SQLITE_OK else {
                print("Error preparing update statement")
                return false
            }

            defer { sqlite3_finalize(statement) }

            sqlite3_bind_text(statement, 1, (user.name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(user.age))
            sqlite3_bind_text(statement, 3, (user.lifePhase as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (user.regularCycle ? "true" : "false" as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 5, Int32(user.cycleLength))
            let contraceptionsString = user.contraceptions.joined(separator: ",")
            sqlite3_bind_text(statement, 5, (contraceptionsString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 6, (user.fertilityGoal as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully updated user")
                return true
            } else {
                if let error = sqlite3_errmsg(db) {
                    print("Failed to update user: \(String(cString: error))")
                }
                return false
            }
        }
}

