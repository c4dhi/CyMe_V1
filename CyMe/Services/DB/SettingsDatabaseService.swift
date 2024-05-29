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
    }
    
    public func getDefaultSettings() -> SettingsModel {
            return SettingsModel(
                enableHealthKit: false,
                HealthDataSettings: getDefaultHealthDataSettings(),
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
            HealthDataSettingsModel(title: "Menstrual data", enableDataSync: true, enableSelfReportingCyMe: true, dataLocation: DataLocation.sync),
            HealthDataSettingsModel(title: "Sleep quality", enableDataSync: false, enableSelfReportingCyMe: false, dataLocation: DataLocation.onlyCyMe),
            HealthDataSettingsModel(title: "Sleep length",enableDataSync: false, enableSelfReportingCyMe: false, dataLocation: DataLocation.sync),
            HealthDataSettingsModel(title:"Headache", enableDataSync: false, enableSelfReportingCyMe: false, dataLocation: DataLocation.sync),
            HealthDataSettingsModel(title: "Stress", enableDataSync: false, enableSelfReportingCyMe: false, dataLocation: DataLocation.onlyCyMe),
            HealthDataSettingsModel(title: "Abdominal cramps", enableDataSync: false, enableSelfReportingCyMe: false, dataLocation: DataLocation.sync),
            HealthDataSettingsModel(title: "Lower back pain", enableDataSync: false, enableSelfReportingCyMe: false, dataLocation: DataLocation.sync),
            HealthDataSettingsModel(title: "Pelvic pain", enableDataSync: false, enableSelfReportingCyMe: false, dataLocation: DataLocation.sync),
            HealthDataSettingsModel(title: "Acne", enableDataSync: false, enableSelfReportingCyMe: false, dataLocation: DataLocation.sync),
            HealthDataSettingsModel(title: "Appetite changes", enableDataSync: false, enableSelfReportingCyMe: false, dataLocation: DataLocation.sync),
            HealthDataSettingsModel(title: "Tightness or pain in the chest", enableDataSync: false, enableSelfReportingCyMe: false, dataLocation: DataLocation.sync),
            HealthDataSettingsModel(title: "Step data", enableDataSync: false, enableSelfReportingCyMe: false, dataLocation: DataLocation.onlyAppleHealth)
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
            print("Settings table created successfully or already exists")
        } else {
            print("Error creating settings table")
        }
    }
    
    private func createHealthDataSettingsTableIfNeeded() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS HealthDataSettings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT,
                enableDataSync TEXT,
                enableSelfReportingCyMe TEXT
            );
            """
        
        if DatabaseService.shared.executeQuery(createTableQuery) {
            print("Health data Settings table created successfully or already exists")
        } else {
            print("Error creating health data settings table")
        }
    }
    
    
    // Saved the whole model in the respective database
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
            _ = updateMainSettings(settings: settings)
            _ = updateHealthDataSettings(healthDataSettings: settings.HealthDataSettings)
        } else {
            _ = insertMainSettings(settings: settings)
            insertHealthDataSettings(healthDataSettings: settings.HealthDataSettings)
        }
    }
    
    // Get the whole Settings model
    private func getSettings() -> SettingsModel? {
        let query = "SELECT * FROM settings LIMIT 1;"
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing select statement")
            return nil
        }
        
        defer { sqlite3_finalize(statement) }
        
        if sqlite3_step(statement) == SQLITE_ROW {
            let enableHealthKit = String(cString: sqlite3_column_text(statement, 1)) == "true"
            let selfReportWithWatch = String(cString: sqlite3_column_text(statement, 2)) == "true"
            let enableWidget = String(cString: sqlite3_column_text(statement, 3)) == "true"
            let startPeriodReminderData = Data(base64Encoded: String(cString: sqlite3_column_text(statement, 4))) ?? Data()
            let selfReportReminderData = Data(base64Encoded: String(cString: sqlite3_column_text(statement, 5))) ?? Data()
            let summaryReminderData = Data(base64Encoded: String(cString: sqlite3_column_text(statement, 6))) ?? Data()
            let selectedThemeName = String(cString: sqlite3_column_text(statement, 7))
            
            //TODO parse them correctly
            let startPeriodReminder = ReminderModel(isEnabled: false, frequency: "", times: [], startDate: Date())
            let selfReportReminder = ReminderModel(isEnabled: false, frequency: "", times: [], startDate: Date())
            let summaryReminder = ReminderModel(isEnabled: false, frequency: "", times: [], startDate: Date())
            
            let selectedTheme = ThemeModel(name: selectedThemeName, backgroundColor: .white, primaryColor: .blue, accentColor: .blue)
            
            var healthDataSettings = getHealthDataSettings()
            
            return SettingsModel(
                enableHealthKit: enableHealthKit,
                HealthDataSettings: healthDataSettings,
                selfReportWithWatch: selfReportWithWatch,
                enableWidget: enableWidget,
                startPeriodReminder: startPeriodReminder,
                selfReportReminder: selfReportReminder,
                summaryReminder: summaryReminder,
                selectedTheme: selectedTheme
            )
        } else {
            print("Settings not found")
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
            print("Error preparing insert statement")
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
            print("Successfully inserted settings")
            return true
        } else {
            if let error = sqlite3_errmsg(db) {
                print("Failed to insert settings: \(String(cString: error))")
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
                selectedTheme = ?,
                WHERE id = 1;
            """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, updateQuery, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing update statement")
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
            print("Successfully updated settings")
            return true
        } else {
            if let error = sqlite3_errmsg(db) {
                print("Failed to update settings: \(String(cString: error))")
            }
            return false
        }
    }
    
// --------------------------------------- HealthData Settings ------------------------------------------------
    private func insertHealthDataSettings(healthDataSettings: [HealthDataSettingsModel]) {
        let selectQuery = "SELECT COUNT(*) FROM HealthDataSettings;"
        var stmt: OpaquePointer?
        var count: Int = 0

        if sqlite3_prepare_v2(db, selectQuery, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                count = Int(sqlite3_column_int(stmt, 0))
            }
            sqlite3_finalize(stmt)
        }

        if count == 0 {
            for healthData in healthDataSettings {
                let insertQuery = """
                    INSERT INTO HealthDataSettings (title, enableDataSync, enableSelfReportingCyMe)
                    VALUES ('\(healthData.title)', '\(healthData.enableDataSync)', '\(healthData.enableSelfReportingCyMe)');
                    """
                if DatabaseService.shared.executeQuery(insertQuery) {
                    print("Default value inserted successfully: \(healthData.title)")
                } else {
                    print("Error inserting default value: \(healthData.title)")
                }
            }
            print("Default values inserted successfully")
        } else {
            print("Default values already exist")
        }
    }

    
    private func updateHealthDataSettings(healthDataSettings: [HealthDataSettingsModel]) -> [HealthDataSettingsModel]?  {
        let updateQuery = """
            UPDATE HealthDataSettings SET
            enableDataSync = ?,
            enableSelfReportingCyMe = ?
            WHERE title = ?;
            """
        
        var success = true
        
        for healthDataSetting in healthDataSettings {
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, updateQuery, -1, &statement, nil) == SQLITE_OK else {
                print("Error preparing update statement")
                success = false
                continue
            }
            
            defer { sqlite3_finalize(statement) }
            
            sqlite3_bind_text(statement, 1, boolToNSStringUTF8String(healthDataSetting.enableDataSync), -1, nil)
            sqlite3_bind_text(statement, 2, boolToNSStringUTF8String(healthDataSetting.enableSelfReportingCyMe), -1, nil)
            sqlite3_bind_text(statement, 3, (healthDataSetting.title as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                success = false
                if let error = sqlite3_errmsg(db) {
                    print("Failed to update health data setting with title \(healthDataSetting.title): \(String(cString: error))")
                }
            }
        }
        
        if success {
            print("Successfully updated health data settings")
            return healthDataSettings
        }
        
        return nil
    }


    
    private func getHealthDataSettings() -> [HealthDataSettingsModel] {
        var settings: [HealthDataSettingsModel] = []
        let selectQuery = "SELECT title, enableDataSync, enableSelfReportingCyMe, dataLocation FROM HealthDataSettings;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, selectQuery, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let title = String(cString: sqlite3_column_text(stmt, 0))
                let enableDataSyncText = String(cString: sqlite3_column_text(stmt, 1))
                let enableSelfReportingCyMeText = String(cString: sqlite3_column_text(stmt, 2))
                let dataLocation = String(cString: sqlite3_column_text(stmt, 3))
                
                settings.append(HealthDataSettingsModel(title: title, enableDataSync: stringToBool(enableDataSyncText), enableSelfReportingCyMe: stringToBool(enableSelfReportingCyMeText), dataLocation: stringToDataLocation(dataLocation) ?? DataLocation.onlyCyMe))
            }
            sqlite3_finalize(stmt)
        } else {
            print("Error preparing select statement")
        }

        return settings
    }


    
    
    
    

}
