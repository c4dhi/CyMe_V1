//
//  RelevantDataTests.swift
//  CyMeTests
//
//  Created by Deborah on 01.08.2024.
//

import Foundation
import XCTest
@testable import CyMe

final class RelevantDataTests: XCTestCase {
    var settingsDatabaseService : SettingsDatabaseService!
    var relevantData: RelevantData!
   

    
    override func setUpWithError() throws {
        settingsDatabaseService = SettingsDatabaseService()
        
        // Mock database entries
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
                enableDataSync: true,
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
                enableDataSync: true,
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
                enableSelfReportingCyMe: true,
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
                questionType: .amountOfSteps
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
                questionType: .amountOfhour
            )
        ]
        
        let settings = SettingsModel(enableHealthKit: true,
                                 healthDataSettings: defaultValues,
                                 selfReportWithWatch: true,
                                 enableWidget: true, 
                                 startPeriodReminder: ReminderModel(isEnabled: false, frequency: "biweekly", times: [], startDate: Date()),
                                 selfReportReminder: ReminderModel(isEnabled: false, frequency: "biweekly", times: [], startDate: Date()),
                                 summaryReminder: ReminderModel(isEnabled: false, frequency: "biweekly", times: [], startDate: Date()),
                                     selectedTheme: ThemeModel(name: "", backgroundColor: .blue, primaryColor: .blue, accentColor: .blue))
        settingsDatabaseService.saveSettings(settings: settings)
        
        relevantData = RelevantData()
    }

    override func tearDownWithError() throws {
        settingsDatabaseService = nil
        relevantData = nil
    }
    


    func testRelevantDataLists() async throws {
        await relevantData.getRelevantDataLists()
        
        let expectedDisplay : [availableHealthMetrics] = [.menstrualBleeding, .menstrualStart, .sleepLength, .pelvicPain, .chestTightnessOrPain]
        let expectedAppleHealth : [availableHealthMetrics] = [.sleepLength, .pelvicPain]
        let expectedCyMeSelfreport : [availableHealthMetrics] = [.menstrualBleeding, .menstrualStart, .chestTightnessOrPain]
        
        XCTAssertEqual(relevantData.relevantForDisplay, expectedDisplay)
        XCTAssertEqual(relevantData.relevantForAppleHealth, expectedAppleHealth)
        XCTAssertEqual(relevantData.relevantForCyMeSelfReport, expectedCyMeSelfreport)
    

       
    }


}
