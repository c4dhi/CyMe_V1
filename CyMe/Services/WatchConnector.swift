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
        print("watchConnector: ", activationState)
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print(message)
        if let selfReportData = message["selfReportData"] as? Data {
            do {
                let selfReport = try JSONDecoder().decode(SelfReportModel.self, from: selfReportData)
                print("Received self-report data from Watch app: \(selfReport)")
                
                if reportingDatabaseService.saveReporting(report: selfReport) {
                    print("Report saved successfully")
                } else {
                    print("Failed to save report")
                }
            } catch {
                print("Error decoding self-report data: \(error.localizedDescription)")
            }
        }
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
}

