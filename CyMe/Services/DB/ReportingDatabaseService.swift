//
//  ReportingDatabaseService.swift
//  CyMe
//
//  Created by Marinja Principe on 25.05.24.
//

import Foundation
import SQLite3

class ReportingDatabaseService {
    private var db: OpaquePointer?
    
    init() {
        self.db = DatabaseService.shared.db
        createReportingTableIfNeeded()
    }
    
    private func createReportingTableIfNeeded() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS reports (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timeStarted TEXT,
                timeFinished TEXT,
                isCyMeSelfReport TEXT,
                selfReportMedium TEXT,
                menstruationDate TEXT,
                menstruationStart TEXT,
                sleepQuality TEXT,
                sleepLenght TEXT,
                headache TEXT,
                stress TEXT,
                abdominalCramps TEXT,
                lowerBackPain TEXT,
                pelvicPain TEXT,
                acne TEXT,
                appetiteChanges TEXT,
                chestPain TEXT,
                stepData TEXT,
                mood TEXT,
                notes TEXT
            );
            """
        
        if DatabaseService.shared.executeQuery(createTableQuery) {
            Logger.shared.log("Reporting table created successfully or already exists")
        } else {
            Logger.shared.log("Error creating settireportingngs table")
        }
    }
    
    func saveReporting(report: SelfReportModel) -> Bool {
        let insertQuery = """
            INSERT INTO reports (
                timeStarted,
                timeFinished,
                isCyMeSelfReport,
                selfReportMedium,
                menstruationDate,
                menstruationStart,
                sleepQuality,
                sleepLenght,
                headache,
                stress,
                abdominalCramps,
                lowerBackPain,
                pelvicPain,
                acne,
                appetiteChanges,
                chestPain,
                stepData,
                mood,
                notes
                )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
            """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK else {
            Logger.shared.log("Error preparing insert statement")
            return false
        }
        
        defer { sqlite3_finalize(statement) }
        
        sqlite3_bind_text(statement, 1, dateToStringUTF8(report.startTime), -1, nil)
        sqlite3_bind_text(statement, 2, dateToStringUTF8(report.endTime), -1, nil)
        sqlite3_bind_int(statement, 3, report.isCyMeSelfReport ? 1 : 0)
        sqlite3_bind_text(statement, 4, stringToUTF8(report.selfReportMedium.rawValue), -1, nil)
        
        let titleToSQLiteField: [String: Int32] = [
            "menstruationDate": 5,
            "menstruationStart": 6,
            "sleepQuality": 7,
            "sleepLenght": 8,
            "headache": 9,
            "stress": 10,
            "abdominalCramps": 11,
            "lowerBackPain": 12,
            "pelvicPain": 13,
            "acne": 14,
            "appetiteChanges": 15,
            "chestPain": 16,
            "stepData": 17,
            "mood": 18,
            "notes": 19
        ]
        
        // initialize all possible fields with NULL
        for index in titleToSQLiteField.values {
            sqlite3_bind_null(statement, index)
        }
        
        // overwrite with actual values if they exist
        for reportItem in report.reports {
            if let index = titleToSQLiteField[reportItem.healthDataName] {
                sqlite3_bind_text(statement, index, stringToUTF8(reportItem.reportedValue), -1, nil)
            }
        }
        
        
        if sqlite3_step(statement) == SQLITE_DONE {
            Logger.shared.log("Successfully inserted report")
            return true
        } else {
            if let error = sqlite3_errmsg(db) {
                Logger.shared.log("Failed to insert report: \(String(cString: error))")
            }
            return false
        }
    }
    
    func saveReports(reports: [SelfReportModel]) -> Bool {
        for report in reports {
            if saveReporting(report: report) {
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    func getReports(from startDate: Date, to endDate: Date) -> [ReviewReportModel] {
        var reports: [ReviewReportModel] = []
        
        // Ensure the database connection is available
        guard let db = db else {
            Logger.shared.log("Database connection is not available")
            return reports
        }
        
        let query = """
            SELECT * FROM reports
            WHERE timeFinished >= ? AND timeFinished <= ?
            """
        
        var statement: OpaquePointer?
        
        // Prepare the SQL query
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            Logger.shared.log("Error preparing query statement: \(errmsg)")
            return reports
        }
        
        defer { sqlite3_finalize(statement) }
        
        // Bind the startDate and endDate to the query
        sqlite3_bind_text(statement, 1, dateToStringUTF8(startDate), -1, nil)
        sqlite3_bind_text(statement, 2, dateToStringUTF8(endDate), -1, nil)
        
        while sqlite3_step(statement) == SQLITE_ROW {
            if let report = parseReport(from: statement) {
                reports.append(report)
            }
        }
        
        return reports
    }
    
    private func parseReport(from statement: OpaquePointer?) -> ReviewReportModel? {
        guard
            let timeStartedCString = sqlite3_column_text(statement, 1),
            let timeFinishedCString = sqlite3_column_text(statement, 2),
            let selfReportMediumCString = sqlite3_column_text(statement, 4)
        else {
            return nil
        }
        
        let dateFormatter = ISO8601DateFormatter()
        guard
            let startTime = dateFormatter.date(from: String(cString: timeStartedCString)),
            let endTime = dateFormatter.date(from: String(cString: timeFinishedCString))
        else {
            return nil
        }
        
        let isCyMeSelfReport = sqlite3_column_int(statement, 3) == 1
        let selfReportMedium = selfReportMediumType(rawValue: String(cString: selfReportMediumCString)) ?? .iOSApp
        
        let reviewReport = ReviewReportModel(
            id: Int(sqlite3_column_int(statement, 0)),
            startTime: startTime,
            endTime: endTime,
            isCyMeSelfReport: isCyMeSelfReport,
            selfReportMedium: selfReportMedium,
            menstruationDate: columnValue(statement, index: 5),
            menstruationStart: columnValue(statement, index: 6),
            sleepQuality: columnValue(statement, index: 7),
            sleepLenght: columnValue(statement, index: 8),
            headache: columnValue(statement, index: 9),
            stress: columnValue(statement, index: 10),
            abdominalCramps: columnValue(statement, index: 11),
            lowerBackPain: columnValue(statement, index: 12),
            pelvicPain: columnValue(statement, index: 13),
            acne: columnValue(statement, index: 14),
            appetiteChanges: columnValue(statement, index: 15),
            chestPain: columnValue(statement, index: 16),
            stepData: columnValue(statement, index: 17),
            mood: columnValue(statement, index: 18),
            notes: columnValue(statement, index: 19)
        )
        
        return reviewReport
    }

    // Helper function to safely retrieve column values from SQLite statement
    private func columnValue(_ statement: OpaquePointer?, index: Int32) -> String? {
        if let value = sqlite3_column_text(statement, index) {
            return String(cString: value)
        }
        return nil
    }


}
    
    
