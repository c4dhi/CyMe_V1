//
//  DiscoverView.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//

import SwiftUI
import SigmaSwiftStatistics


struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    
    var body: some View {
        let x = Sigma.average([1, 3, 8])
        // Convert Double to String
        let averageString = String(format: "%.2f", x!)
        // Result: 4.00 (formatted to two decimal places)
        
        VStack {
               
                   Text("This is the discover page \(averageString)")
          
                   Button(action: {
                       viewModel.healthKitService.requestAuthorization()
                           
                       }) {
                           Text("Tap Me")
                               .font(.headline)
                               .foregroundColor(.white)
                               .padding()
                               .background(Color.blue)
                               .cornerRadius(10)
                       }
               }
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView(viewModel: DiscoverViewModel())
    }
}
