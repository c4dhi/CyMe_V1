//
//  ViewController.swift
//  CyMe
//
//  Created by Marinja Principe on 06.05.24.
//

import WatchConnectivity

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject{
    @Published var hasHeadache: Bool = false
    @Published var hasPeriod: Bool = false

    var session: WCSession
    
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState)
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
            // Handle received message from Watch ap
        print(message)
            if let selfReportData = message["selfReportData"] as? Data {
                do {
                    print("In reseive part")
                    // Decode self-report data
                    let selfReport = try JSONDecoder().decode(SelfReportModel.self, from: selfReportData)
                    // Handle received self-report data
                    print("Received self-report data from Watch app: \(selfReport)")
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
                let jsonData = try JSONEncoder().encode(reportOptions)
                
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

