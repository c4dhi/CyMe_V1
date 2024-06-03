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
    var healthkit = HealthKitService()

    var body: some View {
        Text("Personalize CyMe measuring and reporting")
       .font(.title)
       .fontWeight(.bold)
       .padding()
       .frame(maxWidth: .infinity, alignment: .leading)
       .background(settingsViewModel.settings.selectedTheme.primaryColor)
    
        Form {
            Section(header: Text("Health Data Access")) {
                Toggle("Allow access to Apple Health", isOn: $settingsViewModel.settings.enableHealthKit)
                    .onChange(of: settingsViewModel.settings.enableHealthKit) { newValue in
                                if newValue {
                                    healthkit.requestAuthorization();
                                }
                            }
            }

            Section(header: Text("Measurements and reporting")) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("")
                            .frame(width: 120, alignment: .leading)
                        Spacer()
                        Text("Sync with Apple Health")
                            .frame(width: 100, alignment: .center)
                        Spacer()
                        Text("Self-Report in CyMe")
                            .frame(width: 100, alignment: .center)
                    }
                    .font(.headline)
                    
                    
                    ForEach(settingsViewModel.settings.healthDataSettings.indices, id: \.self) { index in
                        let healthData = settingsViewModel.settings.healthDataSettings[index]
                        self.measurementRow(
                            label: healthData.title,
                            measure: $settingsViewModel.settings.healthDataSettings[index].enableDataSync,
                            selfReport: $settingsViewModel.settings.healthDataSettings[index].enableSelfReportingCyMe,
                            syncIsEnabled: true,
                            cyMeSelfReportIsEnabled: true
                        )
                    }

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

    func measurementRow(label: String, measure: Binding<Bool>, selfReport: Binding<Bool>, syncIsEnabled: Bool, cyMeSelfReportIsEnabled: Bool) -> some View {
        HStack {
            Text(label)
                .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            Toggle("", isOn: measure)
                .labelsHidden()
                .frame(width: 100, alignment: .center)
                .disabled(!syncIsEnabled)
            
            Spacer()
            
            Toggle("", isOn: selfReport)
                .labelsHidden()
                .frame(width: 100, alignment: .center)
                .disabled(!cyMeSelfReportIsEnabled)
        }
    }


}

struct PersonalizationView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalizationView(nextPage: {}, settingsViewModel: SettingsViewModel())
    }
}
