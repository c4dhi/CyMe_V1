// SettingsDatabaseService.swift
// CyMe

import Foundation
import SQLite3

class SettingsDatabaseService {
    private var db: OpaquePointer?

    init() {
        self.db = DatabaseService.shared.db
        createSettingsTableIfNeeded()
        createHealthDataSettingsTableIfNeeded()
        if getSettings() == nil {
            let defaultSettings = getDefaultSettings()
            saveSettings(settings: defaultSettings)
        }
    }
    
    public func getDefaultSettings() -> SettingsModel {
            return SettingsModel(
                enableHealthKit: false,
                healthDataSettings: getDefaultHealthDataSettings(),
                selfReportWithWatch: true,
                enableWidget: true,
                startPeriodReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
                selfReportReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
                summaryReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
                selectedTheme: ThemeModel(name: "Deep blue", backgroundColor: .white, primaryColor: .blue, accentColor: .blue)
            )
    }
    
    private func getDefaultHealthDataSettings() -> [HealthDataSettingsModel] {
        let defaultValues: [HealthDataSettingsModel] = [
            HealthDataSettingsModel(
                name: "menstruationDate",
                label: "Menstruation date",
                enableDataSync: false,
                enableSelfReportingCyMe: true,
                dataLocation: .sync,
                question: "Did you have your period today?",
                questionType: .menstruationEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "menstruationStart",
                label: "Menstruation start",
                enableDataSync: false,
                enableSelfReportingCyMe: true,
                dataLocation: .onlyCyMe,
                question: "Is it the first day of your period?",
                questionType: .menstruationStartRating
            ),
            HealthDataSettingsModel(
                name: "sleepQuality",
                label: "Sleep quality",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .onlyCyMe,
                question: "Rate your sleep quality last night",
                questionType: .emoticonRating
            ),
            HealthDataSettingsModel(
                name: "sleepLenght",
                label: "Sleep length",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .sync,
                question: "How many hours did you sleep?",
                questionType: .amountOfhour
            ),
            HealthDataSettingsModel(
                name: "headache",
                label: "Headache",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .sync,
                question: "Did you experience a headache today?",
                questionType: .painEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "stress",
                label: "Stress",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .onlyCyMe,
                question: "Rate your stress level today",
                questionType: .emoticonRating
            ),
            HealthDataSettingsModel(
                name: "abdominalCramps",
                label: "Abdominal cramps",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .sync,
                question: "Did you experience abdominal cramps today?",
                questionType: .painEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "lowerBackPain",
                label: "Lower back pain",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .sync,
                question: "Did you experience lower back pain today?",
                questionType: .painEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "pelvicPain",
                label: "Pelvic pain",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .sync,
                question: "Did you experience pelvic pain today?",
                questionType: .painEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "acne",
                label: "Acne",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .sync,
                question: "Did you have acne today?",
                questionType: .painEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "appetiteChanges",
                label: "Appetite changes",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .sync,
                question: "Did you experience changes in appetite today?",
                questionType: .changeEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "chestPain",
                label: "Chest pain",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .sync,
                question: "Did you experience tightness or pain in the chest today?",
                questionType: .painEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "stepData",
                label: "Step data",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .onlyAppleHealth,
                question: nil,
                questionType: nil
            ),
            HealthDataSettingsModel(
                name: "mood",
                label: "Mood",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .onlyCyMe,
                question: "What mood do you currently have?",
                questionType: .emoticonRating
            ),
            HealthDataSettingsModel(
                name: "exerciseTime",
                label: "Exercise Time",
                enableDataSync: false,
                enableSelfReportingCyMe: false,
                dataLocation: .onlyAppleHealth,
                question: nil,
                questionType: nil
            )
        ]
        return defaultValues
    }

    
    private func createSettingsTableIfNeeded() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS settings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                enableHealthKit TEXT,
                selfReportWithWatch TEXT,
                enableWidget TEXT,
                startPeriodReminder TEXT,
                selfReportReminder TEXT,
                summaryReminder TEXT,
                selectedTheme TEXT
            );
            """
        
        if DatabaseService.shared.executeQuery(createTableQuery) {
            Logger.shared.log("Settings table created successfully or already exists")
        } else {
            Logger.shared.log("Error creating settings table")
        }
    }
    
    private func createHealthDataSettingsTableIfNeeded() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS healthDataSettings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                label TEXT,
                enableDataSync TEXT,
                enableSelfReportingCyMe TEXT,
                dataLocation TEXT,
                question TEXT,
                questionType TEXT
            );
            """
        
        if DatabaseService.shared.executeQuery(createTableQuery) {
            Logger.shared.log("Health data Settings table created successfully or already exists")
        } else {
            Logger.shared.log("Error creating health data settings table")
        }
    }
    
    
    // Saved the whole model in the respective database
    func saveSettings(settings: SettingsModel) {
        let checkQuery = "SELECT COUNT(*) FROM settings;"
        var checkStatement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, checkQuery, -1, &checkStatement, nil) == SQLITE_OK else {
            Logger.shared.log("Error preparing check statement")
            return
        }
        
        defer { sqlite3_finalize(checkStatement) }
        
        guard sqlite3_step(checkStatement) == SQLITE_ROW else {
            Logger.shared.log("Error checking existing settings")
            return
        }
        
        let count = sqlite3_column_int(checkStatement, 0)
        if count > 0 {
            _ = updateMainSettings(settings: settings)
            _ = updateHealthDataSettings(healthDataSettings: settings.healthDataSettings)
        } else {
            _ = insertMainSettings(settings: settings)
            insertHealthDataSettings(healthDataSettings: settings.healthDataSettings)
        }
    }
    
    // Get the whole Settings model
    public func getSettings() -> SettingsModel? {
        let query = "SELECT * FROM settings LIMIT 1;"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            Logger.shared.log("Error preparing select statement")
            return nil
        }

        defer { sqlite3_finalize(statement) }

        if sqlite3_step(statement) == SQLITE_ROW {
            let enableHealthKit = String(cString: sqlite3_column_text(statement, 1)) == "true"
            let selfReportWithWatch = String(cString: sqlite3_column_text(statement, 2)) == "true"
            let enableWidget = String(cString: sqlite3_column_text(statement, 3)) == "true"
            let startPeriodReminderData = String(cString: sqlite3_column_text(statement, 4)).data(using: .utf8) ?? Data()
            let selfReportReminderData = String(cString: sqlite3_column_text(statement, 5)).data(using: .utf8) ?? Data()
            let summaryReminderData = String(cString: sqlite3_column_text(statement, 6)).data(using: .utf8) ?? Data()
            let selectedThemeName = String(cString: sqlite3_column_text(statement, 7))

            let startPeriodReminder = decodeReminderModel(from: startPeriodReminderData)
            let selfReportReminder = decodeReminderModel(from: selfReportReminderData)
            let summaryReminder = decodeReminderModel(from: summaryReminderData)
            let selectedTheme = ThemeModel(name: selectedThemeName, backgroundColor: .white, primaryColor: .blue, accentColor: .blue)

            let healthDataSettings = getHealthDataSettings()

            return SettingsModel(
                enableHealthKit: enableHealthKit,
                healthDataSettings: healthDataSettings,
                selfReportWithWatch: selfReportWithWatch,
                enableWidget: enableWidget,
                startPeriodReminder: startPeriodReminder,
                selfReportReminder: selfReportReminder,
                summaryReminder: summaryReminder,
                selectedTheme: selectedTheme
            )
        } else {
            Logger.shared.log("Settings not found")
            return nil
        }
    }
    
// ---------------------------------------------------- Main Settings -----------------------------------------
    
    private func insertMainSettings(settings: SettingsModel) -> Bool {
        let insertQuery = """
            INSERT INTO settings (
                enableHealthKit,
                selfReportWithWatch,
                enableWidget,
                startPeriodReminder,
                selfReportReminder,
                summaryReminder,
                selectedTheme
                )
            VALUES (?, ?, ?, ?, ?, ?, ?);
            """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK else {
            Logger.shared.log("Error preparing insert statement")
            return false
        }
        
        defer { sqlite3_finalize(statement) }
        
        sqlite3_bind_text(statement, 1, boolToNSStringUTF8String(settings.enableHealthKit), -1, nil)
        sqlite3_bind_text(statement, 2, boolToNSStringUTF8String(settings.selfReportWithWatch), -1, nil)
        sqlite3_bind_text(statement, 3, boolToNSStringUTF8String(settings.enableWidget), -1, nil)
        sqlite3_bind_text(statement, 4, modelToJSONStringUTF8(settings.startPeriodReminder), -1, nil)
        sqlite3_bind_text(statement, 5, modelToJSONStringUTF8(settings.selfReportReminder), -1, nil)
        sqlite3_bind_text(statement, 6, modelToJSONStringUTF8(settings.summaryReminder), -1, nil)
        sqlite3_bind_text(statement, 7, (settings.selectedTheme.name as NSString).utf8String, -1, nil)
        
        
        if sqlite3_step(statement) == SQLITE_DONE {
            Logger.shared.log("Successfully inserted settings")
            return true
        } else {
            if let error = sqlite3_errmsg(db) {
                Logger.shared.log("Failed to insert settings: \(String(cString: error))")
            }
            return false
        }
    }

    private func updateMainSettings(settings: SettingsModel) -> Bool {
        let updateQuery = """
            UPDATE settings SET
                enableHealthKit = ?,
                selfReportWithWatch = ?,
                enableWidget = ?,
                startPeriodReminder = ?,
                selfReportReminder = ?,
                summaryReminder = ?,
                selectedTheme = ?
            WHERE id = 1;
            """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, updateQuery, -1, &statement, nil) == SQLITE_OK else {
            Logger.shared.log("Error preparing update statement")
            return false
        }
        
        defer { sqlite3_finalize(statement) }
        
        sqlite3_bind_text(statement, 1, boolToNSStringUTF8String(settings.enableHealthKit), -1, nil)
        sqlite3_bind_text(statement, 2, boolToNSStringUTF8String(settings.selfReportWithWatch), -1, nil)
        sqlite3_bind_text(statement, 3, boolToNSStringUTF8String(settings.enableWidget), -1, nil)
        sqlite3_bind_text(statement, 4, modelToJSONStringUTF8(settings.startPeriodReminder), -1, nil)
        sqlite3_bind_text(statement, 5, modelToJSONStringUTF8(settings.selfReportReminder), -1, nil)
        sqlite3_bind_text(statement, 6, modelToJSONStringUTF8(settings.summaryReminder), -1, nil)
        sqlite3_bind_text(statement, 7, (settings.selectedTheme.name as NSString).utf8String, -1, nil)
        
        
        if sqlite3_step(statement) == SQLITE_DONE {
            Logger.shared.log("Successfully updated settings")
            return true
        } else {
            if let error = sqlite3_errmsg(db) {
                Logger.shared.log("Failed to update settings: \(String(cString: error))")
            }
            return false
        }
    }

    
// --------------------------------------- HealthData Settings ------------------------------------------------
    private func insertHealthDataSettings(healthDataSettings: [HealthDataSettingsModel]) {
        let selectQuery = "SELECT COUNT(*) FROM healthDataSettings;"
        var stmt: OpaquePointer?
        var count: Int = 0

        if sqlite3_prepare_v2(db, selectQuery, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                count = Int(sqlite3_column_int(stmt, 0))
            }
            sqlite3_finalize(stmt)
        }

        if count == 0 {
            let insertQuery = """
                INSERT INTO healthDataSettings (name, label, enableDataSync, enableSelfReportingCyMe, dataLocation, question, questionType)
                VALUES (?, ?, ?, ?, ?, ?, ?);
                """
            
            for healthData in healthDataSettings {
                if sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) == SQLITE_OK {
                    sqlite3_bind_text(stmt, 1, stringToUTF8(healthData.name), -1, nil)
                    sqlite3_bind_text(stmt, 2, stringToUTF8(healthData.label), -1, nil)
                    sqlite3_bind_text(stmt, 3, boolToNSStringUTF8String(healthData.enableDataSync), -1, nil)
                    sqlite3_bind_text(stmt, 4, boolToNSStringUTF8String(healthData.enableSelfReportingCyMe), -1, nil)
                    sqlite3_bind_text(stmt, 5, stringToUTF8(healthData.dataLocation.rawValue), -1, nil)
                    sqlite3_bind_text(stmt, 6, stringToUTF8(healthData.question), -1, nil)
                    sqlite3_bind_text(stmt, 7, stringToUTF8(healthData.questionType?.rawValue), -1, nil)
                    
                    if sqlite3_step(stmt) == SQLITE_DONE {
                        Logger.shared.log("Default value inserted successfully: \(healthData.name)")
                    } else {
                        Logger.shared.log("Error inserting default value: \(healthData.name)")
                    }
                    sqlite3_finalize(stmt)
                } else {
                    Logger.shared.log("Error preparing insert statement")
                }
            }
            Logger.shared.log("Default values inserted successfully")
        } else {
            Logger.shared.log("Default values already exist")
        }
    }


    
    private func updateHealthDataSettings(healthDataSettings: [HealthDataSettingsModel]) -> Bool {
        var success = true

        // Begin transaction
        if sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil) != SQLITE_OK {
            Logger.shared.log("Error beginning transaction")
            return false
        }

        let query = """
            UPDATE healthDataSettings SET
                label = ?,
                enableDataSync = ?,
                enableSelfReportingCyMe = ?,
                dataLocation = ?,
                question = ?,
                questionType = ?
            WHERE name = ?;
        """

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            for healthDataSetting in healthDataSettings {
                sqlite3_bind_text(statement, 1, stringToUTF8(healthDataSetting.label), -1, nil)
                sqlite3_bind_text(statement, 2, boolToNSStringUTF8String(healthDataSetting.enableDataSync), -1, nil)
                sqlite3_bind_text(statement, 3, boolToNSStringUTF8String(healthDataSetting.enableSelfReportingCyMe), -1, nil)
                sqlite3_bind_text(statement, 4, dataLocationToUTF8String(healthDataSetting.dataLocation), -1, nil)

                if let question = healthDataSetting.question {
                    sqlite3_bind_text(statement, 5, stringToUTF8(question), -1, nil)
                } else {
                    sqlite3_bind_null(statement, 5)
                }

                if let questionType = healthDataSetting.questionType {
                    sqlite3_bind_text(statement, 6, questionTypeToUTF8String(questionType), -1, nil)
                } else {
                    sqlite3_bind_null(statement, 6)
                }

                sqlite3_bind_text(statement, 7, stringToUTF8(healthDataSetting.name), -1, nil)

                if sqlite3_step(statement) != SQLITE_DONE {
                    Logger.shared.log("Failed to update health data settings for \(healthDataSetting.name)")
                    success = false
                }

                sqlite3_reset(statement)
            }
            sqlite3_finalize(statement)
        } else {
            Logger.shared.log("Error preparing update statement")
            success = false
        }

        // End transaction
        if sqlite3_exec(db, success ? "COMMIT" : "ROLLBACK", nil, nil, nil) != SQLITE_OK {
            Logger.shared.log("Error ending transaction")
            return false
        }

        return success
    }


    
    private func getHealthDataSettings() -> [HealthDataSettingsModel] {
        let query = "SELECT * FROM healthDataSettings;"
        var statement: OpaquePointer?
        var healthDataSettings: [HealthDataSettingsModel] = []

        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            Logger.shared.log("Error preparing select statement for health data settings")
            return healthDataSettings
        }

        defer { sqlite3_finalize(statement) }

        while sqlite3_step(statement) == SQLITE_ROW {
            let name = String(cString: sqlite3_column_text(statement, 1))
            let label = String(cString: sqlite3_column_text(statement, 2))
            let enableDataSync = String(cString: sqlite3_column_text(statement, 3)) == "true"
            let enableSelfReportingCyMe = String(cString: sqlite3_column_text(statement, 4)) == "true"
            let dataLocation = decodeDataLocation(datalocationString: String(cString: sqlite3_column_text(statement, 5))) ?? .onlyCyMe
            
            let question = fetchQuestion(statement: statement, columnIndex: 6)
            let questionTypeString = fetchQuestion(statement: statement, columnIndex: 7)
            let questionType: QuestionType? = questionTypeString != nil ? QuestionType(rawValue: questionTypeString!) : nil

            
            

            let healthDataSetting = HealthDataSettingsModel(
                name: name,
                label: label,
                enableDataSync: enableDataSync,
                enableSelfReportingCyMe: enableSelfReportingCyMe,
                dataLocation: dataLocation,
                question: question,
                questionType: questionType
            )
            healthDataSettings.append(healthDataSetting)
        }
        return healthDataSettings
    }
    
    private func fetchQuestion(statement: OpaquePointer?, columnIndex: Int32) -> String? {
        guard let statement = statement else { return nil }
        guard let cString = sqlite3_column_text(statement, columnIndex) else { return nil }
        return String(cString: cString)
    }

}
