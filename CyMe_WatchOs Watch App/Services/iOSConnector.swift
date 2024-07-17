//
//  InterfaceController.swift
//  CyMe_WatchOs Watch App
//
//  Created by Marinja Principe on 06.05.24.
//

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
            healthDataSettings: [HealthDataSettingsModel(
                    name: "menstruationDate",
                    label: "Menstruation date",
                    enableDataSync: true,
                    enableSelfReportingCyMe: true,
                    dataLocation: .sync,
                    question: "Did you have your period today?",
                    questionType: .menstruationEmoticonRating
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
                    name: "headache",
                    label: "Headache",
                    enableDataSync: false,
                    enableSelfReportingCyMe: true,
                    dataLocation: .sync,
                    question: "Did you experience a headache today?",
                    questionType: .painEmoticonRating
                ),
            ],
            selfReportWithWatch: false,
            enableWidget: false,
            startPeriodReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
            selfReportReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
            summaryReminder: ReminderModel(isEnabled: false, frequency: "Each day", times: [Date()], startDate: Date()),
            selectedTheme: ThemeModel(name: "", backgroundColor: .clear, primaryColor: .clear, accentColor: .clear)
        )
        super.init()
        session.delegate = self
        session.activate()
        
        //loadQuestions()
        loadSelfReports()
    }
    
    private func loadQuestions() {
        self.requestSettingsFromiOS { [weak self] healthSettings in
            if let healthSettings = healthSettings {
                DispatchQueue.main.async {
                    self?.settings.healthDataSettings = healthSettings
                }
            }
        }
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
                }
            } catch {
                print("iOS Connector: Error decoding settings data: \(error.localizedDescription)")
            }
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
}
