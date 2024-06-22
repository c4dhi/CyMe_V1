//
//  InterfaceController.swift
//  CyMe_WatchOs Watch App
//
//  Created by Marinja Principe on 06.05.24.
//

import WatchConnectivity
import SwiftUI

class iOSConnector: NSObject, WCSessionDelegate, ObservableObject{
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
            if let reportOptionsData = message["reportOptions"] as? Data {
                do {
                    // Decode report options data
                    let reportOptions = try JSONDecoder().decode(ReportOptionsModel.self, from: reportOptionsData)
                    
                    // Update userReportingOptions
                    /*DispatchQueue.main.async {
                        self.userReporting.wrappedValue.periodTrackingEnabled = reportOptions.periodTrackingEnabled
                        self.userReporting.wrappedValue.headacheTrackingEnabled = reportOptions.headacheTrackingEnabled
                    }*/

                    print("Received report options: \(reportOptions)")
                } catch {
                    print("Error decoding report options data: \(error.localizedDescription)")
                }
            }
    }
    
    func sendSelfReportDataToiOS(selfReport: SelfReportModel) {
        guard session.isReachable else {
            print("iOS app is not reachable.")
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(selfReport)
            session.sendMessage(["selfReportData": jsonData], replyHandler: nil, errorHandler: { error in
                print("Error sending self-report data: \(error.localizedDescription)")
            })
            print("sending successful")
        } catch {
            print("Error encoding self-report data: \(error.localizedDescription)")
        }
    }

}


