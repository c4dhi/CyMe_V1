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
                isSelfReport TEXT,
                selfReportMedium TEXT,
                menstruationDate TEXT,
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
                mood TEXT
            );
            """
        
        if DatabaseService.shared.executeQuery(createTableQuery) {
            print("Reporting table created successfully or already exists")
        } else {
            print("Error creating settireportingngs table")
        }
    }
    
    func saveReporting(report: SelfReportModel) -> Bool {
        let insertQuery = """
            INSERT INTO reports (
                timeStarted,
                timeFinished,
                isSelfReport,
                selfReportMedium,
                menstruationDate,
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
                mood
                )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
            """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing insert statement")
            return false
        }
        
        defer { sqlite3_finalize(statement) }
        
        sqlite3_bind_text(statement, 1, dateToStringUTF8(report.startTime), -1, nil)
        sqlite3_bind_text(statement, 2, dateToStringUTF8(report.endTime), -1, nil)
        sqlite3_bind_int(statement, 3, report.isSelfReport ? 1 : 0)
        sqlite3_bind_text(statement, 4, stringToUTF8(report.selfReportMedium.rawValue), -1, nil)
        
        let titleToSQLiteField: [String: Int32] = [
            "Menstruation date": 5,
            "Sleep quality": 6,
            "Sleep length": 7,
            "Headache": 8,
            "Stress": 9,
            "Abdominal cramps": 10,
            "Lower back pain": 11,
            "Pelvic pain": 12,
            "Acne": 13,
            "Appetite changes": 14,
            "Chest pain": 15,
            "Step data": 16,
            "Mood": 17
        ]
        
        for reportItem in report.reports {
            
            if let index = titleToSQLiteField[reportItem.healthDataTitle] {
                print(reportItem.healthDataTitle, index)
                sqlite3_bind_text(statement, index, stringToUTF8(reportItem.reportedValue), -1, nil)
            }
        }

        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Successfully inserted report")
            return true
        } else {
            if let error = sqlite3_errmsg(db) {
                print("Failed to insert report: \(String(cString: error))")
            }
            return false
        }
    }
}
