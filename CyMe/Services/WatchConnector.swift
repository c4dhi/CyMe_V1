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
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }

    
    func sendReportOptionsToWatch(reportOptions: ReportOptionsModel) {
        guard session.isReachable else {
            print("Watch app is not reachable.")
            return
        }
        
        do {
            // Encode report options to JSON data
            let jsonData = try JSONEncoder().encode("reportOptions")
            
            // Send data to Watch app
            session.sendMessage(["reportOptions": jsonData], replyHandler: nil, errorHandler: { error in
                print("Error sending report options data: \(error.localizedDescription)")
            })
            print("sending successfull")
        } catch {
            print("Error encoding report options data: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("WatchConnector: Received message: \(message)")

        if let request = message["request"] as? String {
            switch request {
            case "settings":
                sendSettings()
            default:
                print("WatchConnector: Unknown request received from watch app.")
            }
        }

        if let selfReportData = message["selfReportData"] as? Data {
            do {
                let selfReport = try JSONDecoder().decode(SelfReportModel.self, from: selfReportData)
                print("WatchConnector: Received self-report data from Watch app: \(selfReport)")

                if reportingDatabaseService.saveReporting(report: selfReport) {
                    print("WatchConnector: Report saved successfully")
                } else {
                    print("WatchConnector: Failed to save report")
                }
            } catch {
                print("WatchConnector: Error decoding self-report data: \(error.localizedDescription)")
            }
        }
    }
    
    func sendSettings() {
        guard session.isReachable else {
            print("WatchConnector: watch is not reachable.")
            return
        }
        
        let requestData: [String: Any] = ["settings": "test"]
        print("WatchConnector: Sending settings: \(requestData)")
        
        session.sendMessage(requestData, replyHandler: nil, errorHandler: { error in
            print("WatchConnector: Error sending message to watch: \(error.localizedDescription)")
        })
    }
}

