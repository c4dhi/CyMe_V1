//
//  iOSConnector.swift
//  CyMe_WatchOs Watch App
//
//  Created by Marinja Principe on 06.05.24.
//
// Responsible for the connection to the iOS app

import WatchConnectivity
import SwiftUI
import Combine

@MainActor
class iOSConnector: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    @Published var selfReports: [SelfReportModel] = []
    @Published var isLoading = false
    @Published var settings: SettingsModel
    
    init(session: WCSession = .default) {
        self.session = session
        self.settings = SettingsModel(
                    enableHealthKit: false,
                    healthDataSettings: [],
                    selfReportWithWatch: false,
                    enableWidget: false,
                    startPeriodReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
                    selfReportReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
                    summaryReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
                    selectedTheme: ThemeModel(name: "", backgroundColor: .clear, primaryColor: .clear, accentColor: .clear)
                )
        super.init()

        if let savedSettings = loadSettingsFromUserDefaults() {
            self.settings.healthDataSettings = savedSettings
        } else {
            self.settings.healthDataSettings = getDefaultHealthDataSettings()
        }
        
        session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("iOS Connector: ", activationState)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("iOS Connector: Received message: \(message)")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("iOS Connector: Received application context: \(applicationContext)")

        if let settingsData = applicationContext["settings"] as? Data {
            do {
                let settings = try JSONDecoder().decode([HealthDataSettingsModel].self, from: settingsData)
                print("iOS Connector: Updated settings received from iOS app: \(settings)")
                DispatchQueue.main.async {
                    self.settings.healthDataSettings = settings
                    self.saveSettingsToUserDefaults(settings)
                }
            } catch {
                print("iOS Connector: Error decoding settings data: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveSettingsToUserDefaults(_ settings: [HealthDataSettingsModel]) {
            do {
                let settingsData = try JSONEncoder().encode(settings)
                UserDefaults.standard.set(settingsData, forKey: "HealthDataSettings")
                UserDefaults.standard.synchronize() // Optional in modern iOS/watchOS versions
                print("Saved settings to UserDefaults on watchOS")
            } catch {
                print("Error saving settings to UserDefaults on watchOS: \(error.localizedDescription)")
            }
        }

    func requestSettingsFromiOS(completion: @escaping ([HealthDataSettingsModel]?) -> Void) {
        guard session.isReachable else {
            print("iOS Connector: iOS app is not reachable.")
            completion(nil)
            return
        }
        
        let requestData: [String: Any] = ["request": "settings"]
        print("iOS Connector: Sending settings request: \(requestData)")
        
        session.sendMessage(requestData, replyHandler: { response in
            if let settingsData = response["settings"] as? Data {
                let decoder = JSONDecoder()
                if let healthSettings = try? decoder.decode([HealthDataSettingsModel].self, from: settingsData) {
                    DispatchQueue.main.async {
                        completion(healthSettings)
                    }
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }, errorHandler: { error in
            print("iOS Connector: Error sending message to iOS app: \(error.localizedDescription)")
            completion(nil)
        })
    }

    func sendSelfReportDataToiOS(selfReport: SelfReportModel, completion: @escaping (Bool, String) -> Void) {
        guard session.isReachable else {
            print("iOS Connector: iOS app is not reachable.")
            // store the report for later
            storeSelfReport(selfReport)
            completion(false, "iOS app is not reachable. Data stored for later.")
            return
        }
        
        do {
            self.selfReports.append(selfReport)
            print("reports", selfReports)
            let jsonData = try JSONEncoder().encode(selfReports)
            
            session.sendMessage(["selfReportList": jsonData], replyHandler: { response in
                print("iOS Connector: Self-report data sent successfully.")
                DispatchQueue.main.async {
                    self.isLoading = false
                    // clear the list of self-reports on successful send
                    self.selfReports.removeAll()
                    self.saveUnsentSelfReports()
                    completion(true, "Self-report data sent successfully.")
                }
            }, errorHandler: { error in
                print("iOS Connector: Error sending self-report data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    // store the report for later
                    self.saveUnsentSelfReports()
                    completion(false, "Error sending self-report data: \(error.localizedDescription)")
                }
            })
        } catch {
            print("iOS Connector: Error encoding self-report data: \(error.localizedDescription)")
            completion(false, "Error encoding self-report data: \(error.localizedDescription)")
        }
    }
    
    private func storeSelfReport(_ selfReport: SelfReportModel) {
        self.selfReports.append(selfReport)
        saveUnsentSelfReports()
        print("iOS Connector: Stored self-report for later sending. Total unsent reports: \(selfReports.count)")
    }
    
    private func saveUnsentSelfReports() {
        do {
            let jsonData = try JSONEncoder().encode(self.selfReports)
            UserDefaults.standard.set(jsonData, forKey: "unsentSelfReports")
        } catch {
            print("iOS Connector: Error saving unsent self-reports: \(error.localizedDescription)")
        }
    }
    private func loadSettingsFromUserDefaults() -> [HealthDataSettingsModel]? {
        if let settingsData = UserDefaults.standard.data(forKey: "HealthDataSettings") {
            do {
                let settings = try JSONDecoder().decode([HealthDataSettingsModel].self, from: settingsData)
                print("Loaded settings from UserDefaults on watchOS")
                return settings
            } catch {
                print("Error loading settings from UserDefaults on watchOS: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    private func loadSelfReports() {
        if let jsonData = UserDefaults.standard.data(forKey: "unsentSelfReports") {
            do {
                self.selfReports = try JSONDecoder().decode([SelfReportModel].self, from: jsonData)
                print("iOS Connector: Loaded unsent self-reports. Total unsent reports: \(selfReports.count)")
            } catch {
                print("iOS Connector: Error loading unsent self-reports: \(error.localizedDescription)")
            }
        }
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
                enableSelfReportingCyMe: true,
                dataLocation: .onlyCyMe,
                question: "Rate your sleep quality last night",
                questionType: .emoticonRating
            ),
            HealthDataSettingsModel(
                name: "sleepLenght",
                label: "Sleep length",
                enableDataSync: false,
                enableSelfReportingCyMe: true,
                dataLocation: .sync,
                question: "How many hours did you sleep?",
                questionType: .amountOfhour
            ),
            HealthDataSettingsModel(
                name: "headache",
                label: "Headache",
                enableDataSync: false,
                enableSelfReportingCyMe: true,
                dataLocation: .sync,
                question: "Did you experience a headache today?",
                questionType: .painEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "stress",
                label: "Stress",
                enableDataSync: false,
                enableSelfReportingCyMe: true,
                dataLocation: .onlyCyMe,
                question: "Rate your stress level today",
                questionType: .emoticonRating
            ),
            HealthDataSettingsModel(
                name: "abdominalCramps",
                label: "Abdominal cramps",
                enableDataSync: false,
                enableSelfReportingCyMe: true,
                dataLocation: .sync,
                question: "Did you experience abdominal cramps today?",
                questionType: .painEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "lowerBackPain",
                label: "Lower back pain",
                enableDataSync: false,
                enableSelfReportingCyMe: true,
                dataLocation: .sync,
                question: "Did you experience lower back pain today?",
                questionType: .painEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "pelvicPain",
                label: "Pelvic pain",
                enableDataSync: false,
                enableSelfReportingCyMe: true,
                dataLocation: .sync,
                question: "Did you experience pelvic pain today?",
                questionType: .painEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "acne",
                label: "Acne",
                enableDataSync: false,
                enableSelfReportingCyMe: true,
                dataLocation: .sync,
                question: "Did you have acne today?",
                questionType: .painEmoticonRating
            ),
            HealthDataSettingsModel(
                name: "appetiteChanges",
                label: "Appetite changes",
                enableDataSync: false,
                enableSelfReportingCyMe: true,
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
                enableSelfReportingCyMe: true,
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
        return defaultValues
    }
}
