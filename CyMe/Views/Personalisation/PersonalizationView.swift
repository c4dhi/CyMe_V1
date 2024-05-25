//
//  Personalisation.swift
//  CyMe
//
//  Created by Marinja Principe on 13.05.24.
//

import SwiftUI

struct PersonalizationView: View {
    var nextPage: () -> Void
    @ObservedObject var settingsViewModel: SettingsViewModel

    var body: some View {
        Text("Personalize CyMe measuring and reporting")
       .font(.title)
       .fontWeight(.bold)
       .padding()
       .frame(maxWidth: .infinity, alignment: .leading)
       .background(settingsViewModel.settings.selectedTheme.primaryColor)
    
        Form {
            Section(header: Text("Health Data Access")) {
                Toggle("Allow access to HealthKit", isOn: $settingsViewModel.settings.enableHealthKit)
                Toggle("Do you have Apple Watch to measure health data?", isOn: $settingsViewModel.settings.measuringWithWatch)
            }

            Section(header: Text("Measurements and reporting")) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("")
                            .frame(width: 120, alignment: .leading)
                        Spacer()
                        Text("Measure")
                            .frame(width: 100, alignment: .center)
                        Spacer()
                        Text("Self-Report")
                            .frame(width: 100, alignment: .center)
                    }
                    .font(.headline)
                    
                    measurementRow(label: "Sleep quality", measure: $settingsViewModel.settings.enableSleepQualityMeasuring, selfReport: $settingsViewModel.settings.enableSleepQualitySelfReporting)
                    measurementRow(label: "Menstrual cycle length", measure: $settingsViewModel.settings.enableSleepLengthMeasuring, selfReport: $settingsViewModel.settings.enableSleepLengthSelfReporting)
                    measurementRow(label: "Heart rate", measure: $settingsViewModel.settings.enableHeartRateMeasuring, selfReport: $settingsViewModel.settings.enableHeartRateReporting)
                    // Add more measurement rows as needed
                }
            }
        }
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

    func measurementRow(label: String, measure: Binding<Bool>, selfReport: Binding<Bool>) -> some View {
        HStack {
            Text(label)
                .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            Toggle("", isOn: measure)
                .labelsHidden()
                .frame(width: 100, alignment: .center)
            
            Spacer()
            
            Toggle("", isOn: selfReport)
                .labelsHidden()
                .frame(width: 100, alignment: .center)
        }
    }
}

struct PersonalizationView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalizationView(nextPage: {}, settingsViewModel: SettingsViewModel())
    }
}
