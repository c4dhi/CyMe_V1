//
//  VisualisationView.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//

import SwiftUI

struct VisualisationView: View {
    @ObservedObject var watchConnector = WatchConnector()
    
    var body: some View {
        VStack {
            Text("This is the visualisation screen")
            Text("HasPeriod: \(String(watchConnector.hasPeriod))")
            Text("HasHeadache: \(String(watchConnector.hasHeadache))")
            
        }
    }
}


struct VisualisationView_Previews: PreviewProvider {
    static var previews: some View {
        VisualisationView()
    }
}

