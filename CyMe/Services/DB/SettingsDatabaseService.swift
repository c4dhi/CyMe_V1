// SettingsDatabaseService.swift
// CyMe

import Foundation
import SQLite3

class SettingsDatabaseService {
    private var db: OpaquePointer?

    init() {
        self.db = DatabaseService.shared.db
        createSettingsTableIfNeeded()
    }

    private func createSettingsTableIfNeeded() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS settings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                enableHealthKit TEXT,
                measuringWithWatch TEXT,
                enableSleepQualityMeasuring TEXT,
                enableSleepQualitySelfReporting TEXT,
                enableSleepLengthMeasuring TEXT,
                enableSleepLengthSelfReporting TEXT,
                enableMenstrualCycleLengthMeasuring TEXT,
                enableMenstrualCycleLengthReporting TEXT,
                enableHeartRateMeasuring TEXT,
                enableHeartRateReporting TEXT,
                selfReportWithWatch TEXT,
                startPeriodReminder TEXT,
                selfReportReminder TEXT,
                summaryReminder TEXT,
                selectedThemeName TEXT,
                enableWidget TEXT
            );
            """
        
        if DatabaseService.shared.executeQuery(createTableQuery) {
            print("Settings table created successfully or already exists")
        } else {
            print("Error creating settings table")
        }
    }

    func saveSettings(settings: SettingsModel) {
        let fetchQuery = "SELECT COUNT(*) FROM settings WHERE id = 1;"
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
            _ = updateSettings(settings: settings)
        } else {
            _ = insertSettings(settings: settings)
        }
    }

    private func insertSettings(settings: SettingsModel) -> Bool {
        let insertQuery = """
            INSERT INTO settings (
                enableHealthKit, connectWatch, enableSleepQualityMeasuring,
                enableSleepQualitySelfReporting, enableSleepLengthMeasuring,
                enableSleepLengthSelfReporting, enableMenstrualCycleLengthMeasuring,
                enableMenstrualCycleLengthReporting, enableHeartRateMeasuring,
                enableHeartRateReporting, selfReportWithWatch TEXT,
                startPeriodReminder TEXT,
                selfReportReminder TEXT,
                summaryReminder TEXT,
                selectedTheme TEXT, enableWidget)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
            """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing insert statement")
            return false
        }
        
        defer { sqlite3_finalize(statement) }
        
        sqlite3_bind_text(statement, 1, (settings.enableHealthKit ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 2, (settings.measuringWithWatch ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 3, (settings.enableSleepQualityMeasuring ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 4, (settings.enableSleepQualitySelfReporting ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 5, (settings.enableSleepLengthMeasuring ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 6, (settings.enableSleepLengthSelfReporting ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 7, (settings.enableMenstrualCycleLengthMeasuring ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 8, (settings.enableMenstrualCycleLengthReporting ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 9, (settings.enableHeartRateMeasuring ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 10, (settings.enableHeartRateReporting ? "true" : "false"), -1, nil)
        //TODO add Models as string to db
        sqlite3_bind_text(statement, 14, (settings.selfReportWithWatch ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 15, (settings.enableWidget ? "true" : "false"), -1, nil)
        
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

    private func updateSettings(settings: SettingsModel) -> Bool {
        let updateQuery = """
            UPDATE settings SET
                enableHealthKit = ?, connectWatch = ?, enableSleepQualityMeasuring = ?,
                enableSleepQualitySelfReporting = ?, enableSleepLengthMeasuring = ?,
                enableSleepLengthSelfReporting = ?, enableMenstrualCycleLengthMeasuring = ?,
                enableMenstrualCycleLengthReporting = ?, enableHeartRateMeasuring = ?,
                enableHeartRateReporting = ?, selfReportingReminderFrequency = ?,
                summaryReminderFrequency = ?, startPeriodReminderFrequency = ?,
                enableSelfReportingOnWatch = ?, enableWidgets = ?
            WHERE id = 1;
            """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, updateQuery, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing update statement")
            return false
        }
        
        defer { sqlite3_finalize(statement) }
        
        sqlite3_bind_text(statement, 1, (settings.enableHealthKit ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 2, (settings.measuringWithWatch ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 3, (settings.enableSleepQualityMeasuring ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 4, (settings.enableSleepQualitySelfReporting ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 5, (settings.enableSleepLengthMeasuring ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 6, (settings.enableSleepLengthSelfReporting ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 7, (settings.enableMenstrualCycleLengthMeasuring ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 8, (settings.enableMenstrualCycleLengthReporting ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 9, (settings.enableHeartRateMeasuring ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 10, (settings.enableHeartRateReporting ? "true" : "false"), -1, nil)
        sqlite3_bind_text(statement, 11, settings.selfReportReminder.frequency, -1, nil)
        sqlite3_bind_text(statement, 12, settings.summaryReminder.frequency, -1, nil)
        sqlite3_bind_text(statement, 13, settings.startPeriodReminder.frequency, -1, nil)
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Successfully updated settings")
            return true
        } else {
            if let error = sqlite3_errmsg(db) {
                print("Failed to update settings: \(String(cString: error))")
            }
            return false
        }
    }
    private func defaultSettings() -> SettingsModel {
            return SettingsModel(
                enableHealthKit: false,
                measuringWithWatch: true,
                enableSleepQualityMeasuring: true,
                enableSleepQualitySelfReporting: false,
                enableSleepLengthMeasuring: true,
                enableSleepLengthSelfReporting: false,
                enableMenstrualCycleLengthMeasuring: true,
                enableMenstrualCycleLengthReporting: false,
                enableHeartRateMeasuring: false,
                enableHeartRateReporting: true,
                selfReportWithWatch: true,
                startPeriodReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
                selfReportReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
                summaryReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
                selectedTheme: ThemeModel(name: "Deep blue", backgroundColor: .white, primaryColor: .blue, accentColor: .blue),
                enableWidget: true
            )
        }
    
    func getSettings() -> SettingsModel {
        let query = "SELECT * FROM settings WHERE id = 1;"
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing select statement")
            return defaultSettings()
        }
        
        defer { sqlite3_finalize(statement) }
        
        if sqlite3_step(statement) == SQLITE_ROW {
            let enableHealthKit = String(cString: sqlite3_column_text(statement, 1)) == "true"
            let measuringWithWatch = String(cString: sqlite3_column_text(statement, 2)) == "true"
            let enableSleepQualityMeasuring = String(cString: sqlite3_column_text(statement, 3)) == "true"
            let enableSleepQualitySelfReporting = String(cString: sqlite3_column_text(statement, 4)) == "true"
            let enableMenstrualCycleLengthMeasuring = String(cString: sqlite3_column_text(statement, 5)) == "true"
            let enableMenstrualCycleLengthReporting = String(cString: sqlite3_column_text(statement, 6)) == "true"
            let enableHeartRateMeasuring = String(cString: sqlite3_column_text(statement, 7)) == "true"
            let enableHeartRateReporting = String(cString: sqlite3_column_text(statement, 8)) == "true"
            let selfReportReminderData = Data(base64Encoded: String(cString: sqlite3_column_text(statement, 9))) ?? Data()
            let summaryReminderData = Data(base64Encoded: String(cString: sqlite3_column_text(statement, 10))) ?? Data()
            let startPeriodReminderData = Data(base64Encoded: String(cString: sqlite3_column_text(statement, 11))) ?? Data()
            //TODO get the models
            let selfReportReminder = ReminderModel(isEnabled: false, frequency: "", times: [], startDate: Date())
            let summaryReminder = ReminderModel(isEnabled: false, frequency: "", times: [], startDate: Date())
            let startPeriodReminder = ReminderModel(isEnabled: false, frequency: "", times: [], startDate: Date())
            
            return SettingsModel(
                enableHealthKit: enableHealthKit,
                measuringWithWatch: measuringWithWatch,
                enableSleepQualityMeasuring: enableSleepQualityMeasuring,
                enableSleepQualitySelfReporting: enableSleepQualitySelfReporting,
                enableSleepLengthMeasuring: enableSleepQualityMeasuring,
                enableSleepLengthSelfReporting: enableSleepQualitySelfReporting,
                enableMenstrualCycleLengthMeasuring: enableMenstrualCycleLengthMeasuring,
                enableMenstrualCycleLengthReporting: enableMenstrualCycleLengthReporting,
                enableHeartRateMeasuring: enableHeartRateMeasuring,
                enableHeartRateReporting: enableHeartRateReporting,
                selfReportWithWatch: true,
                startPeriodReminder: selfReportReminder ?? ReminderModel(isEnabled: false, frequency: "", times: [], startDate: Date()),
                selfReportReminder: summaryReminder ?? ReminderModel(isEnabled: false, frequency: "", times: [], startDate: Date()),
                summaryReminder: startPeriodReminder ?? ReminderModel(isEnabled: false, frequency: "", times: [], startDate: Date()),
                selectedTheme: ThemeModel(name: "Deep blue", backgroundColor: .white, primaryColor: .blue, accentColor: .blue),
                enableWidget: true
            )
        } else {
            print("Settings not found, returning default settings")
            return defaultSettings()
        }
    }


}
