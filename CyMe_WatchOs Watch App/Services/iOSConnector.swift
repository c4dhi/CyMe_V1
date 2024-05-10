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
    var userReporting: Binding<UserReportingOptions>
    
    init(session: WCSession = .default, userReporting: Binding<UserReportingOptions>) {
        self.session = session
        self.userReporting = userReporting
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
            if let reportOptionsData = message["reportOptions"] as? Data {
                do {
                    // Decode report options data
                    let reportOptions = try JSONDecoder().decode(ReportOptionsModel.self, from: reportOptionsData)
                    
                    // Update userReportingOptions
                    DispatchQueue.main.async {
                        self.userReporting.wrappedValue.periodTrackingEnabled = reportOptions.periodTrackingEnabled
                        self.userReporting.wrappedValue.headacheTrackingEnabled = reportOptions.headacheTrackingEnabled
                    }

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
            // Encode selfReport to JSON data
            let jsonData = try JSONEncoder().encode(selfReport)
            
            
            // Send data to iOS app
            session.sendMessage(["selfReportData": jsonData], replyHandler: nil, errorHandler: { error in
                print("Error sending self-report data: \(error.localizedDescription)")
            })
            print("sending successfull")
        } catch {
            print("Error encoding self-report data: \(error.localizedDescription)")
        }
    }

}


