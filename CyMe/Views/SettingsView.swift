//
//  SettingsView.swift
//  CyMe
//
//  Created by Marinja Principe on 08.05.24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("periodTrackingEnabled") private var periodTrackingEnabled = true
    @AppStorage("headacheTrackingEnabled") private var headacheTrackingEnabled = true
    @Binding var isPresented: Bool
    @StateObject var connector = WatchConnector()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Period Tracking")) {
                    Toggle("Enable Period Tracking", isOn: $periodTrackingEnabled)
                }
                Section(header: Text("Headache Tracking")) {
                    Toggle("Enable Period Tracking", isOn: $headacheTrackingEnabled)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                // Dismiss settings view
                isPresented = false
                submitToWatch()
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func submitToWatch() {
        // Create a report options model with the updated tracking preferences
        let reportOptions = ReportOptionsModel(periodTrackingEnabled: periodTrackingEnabled, headacheTrackingEnabled: headacheTrackingEnabled)

        // Send the report options data to the Watch
        connector.sendReportOptionsToWatch(reportOptions: reportOptions)
    }


}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true))
    }
}
