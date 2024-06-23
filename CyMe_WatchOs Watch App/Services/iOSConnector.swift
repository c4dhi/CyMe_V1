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
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("iOS Connector: ", activationState)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("iOS Connector: Received message: \(message)")
        
        if let data = message["settings"] as? String {
            switch data {
            case "test":
                print("test")
            default:
                print("iOS Connector: Unknown request received from watch app.")
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

    func updateSettings(_ settings: HealthDataSettingsModel) {
       print("iOS Connector: Updated settings: \(settings)")
    }

    func sendSelfReportDataToiOS(selfReport: SelfReportModel) {
        guard session.isReachable else {
            print("iOS Connector: iOS app is not reachable.")
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(selfReport)
            session.sendMessage(["selfReportData": jsonData], replyHandler: nil, errorHandler: { error in
                print("iOS Connector: Error sending self-report data: \(error.localizedDescription)")
            })
            print("iOS Connector: Self-report data sent successfully.")
        } catch {
            print("iOS Connector: Error encoding self-report data: \(error.localizedDescription)")
        }
    }
}
