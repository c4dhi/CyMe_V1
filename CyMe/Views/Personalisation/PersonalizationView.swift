//
//  Personalisation.swift
//  CyMe
//
//  Created by Marinja Principe on 13.05.24.
//

import SwiftUI

struct PersonalizationView: View {
    var nextPage: () -> Void
    @State private var isHealthKitEnabled = false
    @State private var measureSleep = true
    @State private var selfReportSleep = false
    @State private var measureLength = true
    @State private var selfReportLength = false
    @State private var measureHeartRate = false
    @State private var selfReportHeartRate = true
    // Add more variables for other measurements as needed
    
    var body: some View {
        VStack {
            Text("Personalize CyMe self-reporting")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Toggle("Allow access to HealthKit", isOn: $isHealthKitEnabled)
                .padding()
            
            Text("Measurements")
                .font(.headline)
                .padding(.bottom)
            
            VStack(alignment: .trailing) {
                HStack {
                    Text("                    ")
                        .font(.headline)
                    Spacer()
                    Text("Measure")
                        .font(.headline)
                    Spacer()
                    Text("Self-Report")
                        .font(.headline)
                    Spacer()
                }
                
                measurementRow(label: "Sleep quality", measure: $measureSleep, selfReport: $selfReportSleep)
                measurementRow(label: "Menstrual cycle length", measure: $measureLength, selfReport: $selfReportLength)
                measurementRow(label: "Heart rate", measure: $measureHeartRate, selfReport: $selfReportHeartRate)
                // Add more measurement rows as needed
            }
            .padding()
            
            Spacer()
            Button(action: nextPage) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    func measurementRow(label: String, measure: Binding<Bool>, selfReport: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .font(.headline)
            
            Spacer()
            
            Toggle("", isOn: measure)
            
            Spacer()
            
            Toggle("", isOn: selfReport)
            
            Spacer()
        }
    }
}

struct PersonalizationView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalizationView(nextPage: {})
    }
}
