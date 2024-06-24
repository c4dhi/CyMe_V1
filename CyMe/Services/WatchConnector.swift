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
    @Published var settingsViewModel: SettingsViewModel
    
    init(session: WCSession = .default, reportingDatabaseService: ReportingDatabaseService = ReportingDatabaseService()) {
        self.session = session
        self.reportingDatabaseService = reportingDatabaseService
        self.settingsViewModel = SettingsViewModel()
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("watchConnector: ", activationState)
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("watchConnector: Session became inactive and reactivated")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("watchConnector: Session deactivated and reactivated")
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        print("watchConnector: Session reachability changed to \(session.isReachable)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("WatchConnector: Received message with reply handler: \(message)")

        if let request = message["request"] as? String {
            switch request {
            case "settings":
                sendSettings()
            default:
                print("WatchConnector: Unknown request received from watch app.")
            }
        }

        if let selfReportList = message["selfReportList"] as? Data {
            do {
                let selfReports = try JSONDecoder().decode([SelfReportModel].self, from: selfReportList)
                print("WatchConnector: Received self-report data from Watch app: \(selfReports)")

                if reportingDatabaseService.saveReports(reports: selfReports) {
                    print("WatchConnector: Report saved successfully")
                } else {
                    print("WatchConnector: Failed to save report")
                }

                // Example of replying back to the watch app
                replyHandler(["status": "Received and processed self-report data"])
            } catch {
                print("WatchConnector: Error decoding self-report data: \(error.localizedDescription)")
                replyHandler(["error": error.localizedDescription])
            }
        }
    }
    
    func sendSettings() {
        guard session.isReachable else {
            print("WatchConnector: Watch is not reachable.")
            return
        }

        do {
            let jsonData = try JSONEncoder().encode(settingsViewModel.settings.healthDataSettings)
            print("WatchConnector: Attempting to update application context with settings: \(settingsViewModel.settings.healthDataSettings)")
            
            try session.updateApplicationContext(["settings": jsonData])
            print("WatchConnector: update Application Context successful")
        } catch {
            print("WatchConnector: Error encoding settings: \(error.localizedDescription)")
        }
    }
}

