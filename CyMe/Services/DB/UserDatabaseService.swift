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
                    userId TEXT,
                    name TEXT,
                    age INTEGER,
                    lifePhase TEXT,
                    regularCycle TEXT,
                    cycleLength INTEGER,
                    contraceptions TEXT,
                    fertilityGoal TEXT
                );
                """
            
            if DatabaseService.shared.executeQuery(createTableQuery) {
                Logger.shared.log("User table created successfully or already exists")
            } else {
                Logger.shared.log("Error creating user table")
            }
        }
    
        func isUserPresent() -> Bool {
            // Implement the logic to check if the user is present in the database
            let query = "SELECT COUNT(*) FROM user;"
            var statement: OpaquePointer?
            
            guard sqlite3_prepare_v2(DatabaseService.shared.db, query, -1, &statement, nil) == SQLITE_OK else {
                if let error = sqlite3_errmsg(DatabaseService.shared.db) {
                    Logger.shared.log("Error preparing statement: \(String(cString: error))")
                }
                return false
            }
            
            defer { sqlite3_finalize(statement) }
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let count = sqlite3_column_int(statement, 0)
                return count > 0
            } else {
                if let error = sqlite3_errmsg(DatabaseService.shared.db) {
                    Logger.shared.log("Error executing query: \(String(cString: error))")
                }
                return false
            }
        }
    
        func getUserName() -> String? {
            let query = "SELECT name FROM user LIMIT 1;"
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
                Logger.shared.log("Error preparing query")
                return nil
            }
            
            defer {
                sqlite3_finalize(statement)
            }
            
            guard sqlite3_step(statement) == SQLITE_ROW else {
                Logger.shared.log("No rows found")
                return nil
            }
            
            guard let namePtr = sqlite3_column_text(statement, 0) else {
                Logger.shared.log("No name found")
                return nil
            }
            
            return String(cString: namePtr)
        }
        
        func saveUser(user: UserModel) {
            let fetchQuery = "SELECT COUNT(*) FROM user WHERE id = 1;"
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, fetchQuery, -1, &statement, nil) == SQLITE_OK else {
                Logger.shared.log("Error preparing fetch statement")
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
                Logger.shared.log("Error preparing select statement")
                return defaultUser()
            }

            defer { sqlite3_finalize(statement) }

            if sqlite3_step(statement) == SQLITE_ROW {
                let userId = String(cString: sqlite3_column_text(statement, 1))
                let name = String(cString: sqlite3_column_text(statement, 2))
                let age = Int(sqlite3_column_int(statement, 3))
                let lifePhase = String(cString: sqlite3_column_text(statement, 4))
                let regularCycle = String(cString: sqlite3_column_text(statement, 5)) == "true"
                let cycleLength: Int?
                if sqlite3_column_type(statement, 6) == SQLITE_NULL {
                    cycleLength = nil
                } else {
                    cycleLength = Int(sqlite3_column_int(statement, 6))
                }

                let contraceptionsString = String(cString: sqlite3_column_text(statement, 7))
                var contraceptions: [String] = []

                if !contraceptionsString.isEmpty {
                    contraceptions = contraceptionsString.split(separator: ",").map { String($0) }
                }
                let fertilityGoal = String(cString: sqlite3_column_text(statement, 8))

                return UserModel(userId: userId, name: name, age: age, lifePhase: lifePhase, regularCycle: regularCycle, cycleLength: cycleLength, contraceptions: contraceptions, fertilityGoal: fertilityGoal)
            } else {
                return defaultUser()
            }
        }

        func defaultUser() -> UserModel {
            return UserModel(userId: "", name: "", age: nil, lifePhase: "Premenopause", regularCycle: false, cycleLength: nil, contraceptions: [], fertilityGoal: "Avoiding pregnancy")
        }


        private func insertUser(user: UserModel) -> Bool {
            let insertQuery = """
                INSERT INTO user (userId, name, age, lifePhase, regularCycle, cycleLength, contraceptions, fertilityGoal)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?);
                """
            
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK else {
                Logger.shared.log("Error preparing insert statement")
                return false
            }
            
            defer {
                sqlite3_finalize(statement)
            }
            
            let contraceptionsString = user.contraceptions.joined(separator: ",")
            sqlite3_bind_text(statement, 1, (user.userId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (user.name as NSString).utf8String, -1, nil)
            if let age = user.age {
                    sqlite3_bind_int(statement, 3, Int32(age))
                } else {
                    sqlite3_bind_null(statement, 3)
                }
            sqlite3_bind_text(statement, 4, (user.lifePhase as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (user.regularCycle ? "true" : "false" as NSString).utf8String, -1, nil)
            if let cycleLength = user.cycleLength {
                    sqlite3_bind_int(statement, 6, Int32(cycleLength))
                } else {
                    sqlite3_bind_null(statement, 6)
                }
            sqlite3_bind_text(statement, 7, (contraceptionsString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 8, (user.fertilityGoal as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                Logger.shared.log("Successfully inserted user")
                return true
            } else {
                if let error = sqlite3_errmsg(db) {
                    Logger.shared.log("Failed to insert user: \(String(cString: error))")
                }
                return false
            }
        }

        private func updateUser(user: UserModel) -> Bool {
            let updateQuery = """
                UPDATE user SET
                    userId = ?, name = ?, age = ?, lifePhase = ?, regularCycle = ?, cycleLength = ?,
                    contraceptions = ?, fertilityGoal = ?
                WHERE id = 1;
                """
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, updateQuery, -1, &statement, nil) == SQLITE_OK else {
                Logger.shared.log("Error preparing update statement")
                return false
            }

            defer { sqlite3_finalize(statement) }
            sqlite3_bind_text(statement, 1, (user.userId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (user.name as NSString).utf8String, -1, nil)
            if let age = user.age {
                    sqlite3_bind_int(statement, 3, Int32(age))
                } else {
                    sqlite3_bind_null(statement, 3)
                }
            sqlite3_bind_text(statement, 4, (user.lifePhase as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (user.regularCycle ? "true" : "false" as NSString).utf8String, -1, nil)
            if let cycleLength = user.cycleLength {
                    sqlite3_bind_int(statement, 6, Int32(cycleLength))
                } else {
                    sqlite3_bind_null(statement, 6)
                }
            let contraceptionsString = user.contraceptions.joined(separator: ",")
            sqlite3_bind_text(statement, 7, (contraceptionsString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 8, (user.fertilityGoal as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) == SQLITE_DONE {
                Logger.shared.log("Successfully updated user")
                return true
            } else {
                if let error = sqlite3_errmsg(db) {
                    Logger.shared.log("Failed to update user: \(String(cString: error))")
                }
                return false
            }
        }
    
    func anonymizeUserTable(at databaseURL: URL) {
        guard let db = openDatabase(at: databaseURL) else { return }

        let fetchUsersQuery = "SELECT id, name FROM user;"
        var fetchStatement: OpaquePointer?

        guard sqlite3_prepare_v2(db, fetchUsersQuery, -1, &fetchStatement, nil) == SQLITE_OK else {
            Logger.shared.log("Error preparing fetch statement")
            return
        }

        defer {
            sqlite3_finalize(fetchStatement)
        }

        while sqlite3_step(fetchStatement) == SQLITE_ROW {
            let id = sqlite3_column_int(fetchStatement, 0)
            let name = String(cString: sqlite3_column_text(fetchStatement, 1))
            let anonymizedCode = generateAnonymizedCode(for: name)

            let updateQuery = "UPDATE user SET name = ? WHERE id = ?;"
            var updateStatement: OpaquePointer?

            guard sqlite3_prepare_v2(db, updateQuery, -1, &updateStatement, nil) == SQLITE_OK else {
                Logger.shared.log("Error preparing update statement")
                continue
            }

            sqlite3_bind_text(updateStatement, 1, (anonymizedCode as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 2, id)

            if sqlite3_step(updateStatement) == SQLITE_DONE {
                Logger.shared.log("Successfully updated user \(id) with anonymized code")
            } else {
                if let error = sqlite3_errmsg(db) {
                    Logger.shared.log("Failed to update user \(id): \(String(cString: error))")
                }
            }

            sqlite3_finalize(updateStatement)
        }

        sqlite3_close(db)
    }
    
    private func openDatabase(at url: URL) -> OpaquePointer? {
        var db: OpaquePointer?
        if sqlite3_open(url.path, &db) == SQLITE_OK {
            Logger.shared.log("Successfully opened connection to database at \(url.path)")
            return db
        } else {
            if let error = sqlite3_errmsg(db) {
                Logger.shared.log("Unable to open database: \(String(cString: error))")
            }
            return nil
        }
    }

   private func generateAnonymizedCode(for name: String) -> String {
       let baseCode = UUID().uuidString.prefix(8)
       return "\(baseCode)"
   }
}

