//
//  ContentView.swift
//  CyMe_WatchOs Watch App
//
//  Created by Marinja Principe on 17.04.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var connector = iOSConnector()
    
    @State private var isSelfReporting = false

    var body: some View {
        VStack {
            
            if isSelfReporting {
                SelfReportWatchView(connector: connector, isSelfReporting: $isSelfReporting)
            } else {
                Button(action: {
                    isSelfReporting = true
                }) {
                    Text("Add New Self-Report")
                        .font(.caption)
                        .padding()
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
