//
//  InterfaceController.swift
//  CyMe_WatchOs Watch App
//
//  Created by Marinja Principe on 06.05.24.
//

import WatchConnectivity
import SwiftUI

class iOSConnector: NSObject, WCSessionDelegate, ObservableObject {
    var session: WCSession
    @Published var selfReports: [SelfReportModel] = []
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
        loadSelfReports()
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
                let settings = try JSONDecoder().decode(HealthDataSettingsModel.self, from: settingsData)
                print("iOS Connector: Updated settings received from iOS app: \(settings)")
                // Update your settings model or state here
            } catch {
                print("iOS Connector: Error decoding settings data: \(error.localizedDescription)")
            }
        }
    }

    func requestSettingsFromiOS() {
        guard session.isReachable else {
            print("iOS Connector: iOS app is not reachable.")
            return
        }
        
        let requestData: [String: Any] = ["request": "settings"]
        print("iOS Connector: Sending settings request: \(requestData)")
        
        session.sendMessage(requestData, replyHandler: nil, errorHandler: { error in
            print("iOS Connector: Error sending message to iOS app: \(error.localizedDescription)")
        })
    }

    func sendSelfReportDataToiOS(selfReport: SelfReportModel) {
        guard session.isReachable else {
            print("iOS Connector: iOS app is not reachable.")
            // store the report for later
            storeSelfReport(selfReport)
            return
        }
        do {
            selfReports.append(selfReport)
            
            let jsonData = try JSONEncoder().encode(selfReports)
            session.sendMessage(["selfReportList": jsonData], replyHandler: { response in
                print("iOS Connector: Self-report data sent successfully.")
                
                // clear the list of self-reports on successful send
                self.selfReports.removeAll()
                self.saveUnsentSelfReports()
            }, errorHandler: { error in
                print("iOS Connector: Error sending self-report data: \(error.localizedDescription)")
                // store the report for later
                self.saveUnsentSelfReports()
            })
        } catch {
            print("iOS Connector: Error encoding self-report data: \(error.localizedDescription)")
        }
    }
    
    private func storeSelfReport(_ selfReport: SelfReportModel) {
        selfReports.append(selfReport)
        saveUnsentSelfReports()
        print("iOS Connector: Stored self-report for later sending. Total unsent reports: \(selfReports.count)")
    }
    
    private func saveUnsentSelfReports() {
        do {
            let jsonData = try JSONEncoder().encode(selfReports)
            UserDefaults.standard.set(jsonData, forKey: "unsentSelfReports")
        } catch {
            print("iOS Connector: Error saving unsent self-reports: \(error.localizedDescription)")
        }
    }
    
    private func loadSelfReports() {
        if let jsonData = UserDefaults.standard.data(forKey: "unsentSelfReports") {
            do {
                selfReports = try JSONDecoder().decode([SelfReportModel].self, from: jsonData)
                print("iOS Connector: Loaded unsent self-reports. Total unsent reports: \(selfReports.count)")
            } catch {
                print("iOS Connector: Error loading unsent self-reports: \(error.localizedDescription)")
            }
        }
    }
}
