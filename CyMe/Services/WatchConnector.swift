//
//  ViewController.swift
//  CyMe
//
//  Created by Marinja Principe on 06.05.24.
//
import Foundation
import WatchConnectivity

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject{

    var session: WCSession
    private var reportingDatabaseService: ReportingDatabaseService
    
    init(session: WCSession = .default, reportingDatabaseService: ReportingDatabaseService = ReportingDatabaseService()) {
        self.session = session
        self.reportingDatabaseService = reportingDatabaseService
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Logger.shared.log("watchConnector: \(activationState)")
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        Logger.shared.log("watchConnector: Session became inactive and reactivated")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        Logger.shared.log("watchConnector: Session deactivated and reactivated")
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        Logger.shared.log("watchConnector: Session reachability changed to \(session.isReachable)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Logger.shared.log("WatchConnector: Received message with reply handler: \(message)")

        /*if let request = message["request"] as? String {
            switch request {
            case "settings":
                sendSettings()
            default:
                Logger.shared.log("WatchConnector: Unknown request received from watch app.")
            }
        }*/

        if let selfReportList = message["selfReportList"] as? Data {
            do {
                let selfReports = try JSONDecoder().decode([SelfReportModel].self, from: selfReportList)
                Logger.shared.log("WatchConnector: Received self-report data from Watch app: \(selfReports)")

                if reportingDatabaseService.saveReports(reports: selfReports) {
                    Logger.shared.log("WatchConnector: Report saved successfully")
                } else {
                    Logger.shared.log("WatchConnector: Failed to save report")
                }

                // Example of replying back to the watch app
                replyHandler(["status": "Received and processed self-report data"])
            } catch {
                Logger.shared.log("WatchConnector: Error decoding self-report data: \(error.localizedDescription)")
                replyHandler(["error": error.localizedDescription])
            }
        }
    }
    
    func sendSettings(settings: SettingsModel) {
        guard session.isReachable else {
            Logger.shared.log("WatchConnector: Watch is not reachable.")
            return
        }

        do {
            let jsonData = try JSONEncoder().encode(settings.healthDataSettings)
            Logger.shared.log("WatchConnector: Sending settings: \(settings.healthDataSettings)")
            try session.updateApplicationContext(["settings": jsonData])
            Logger.shared.log("WatchConnector: Update Application Context successful")
        } catch {
            Logger.shared.log("WatchConnector: Error encoding settings: \(error.localizedDescription)")
        }
    }
}

