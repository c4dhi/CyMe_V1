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
                    hasHeadache = selfReport.hasHeadache
                    hasPeriod = selfReport.hasPeriod
                    // Handle received self-report data
                    print("Received self-report data from Watch app: \(selfReport)")
                } catch {
                    print("Error decoding self-report data: \(error.localizedDescription)")
                }
            }
    }
}

