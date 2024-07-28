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
    @State private var theme: ThemeModel = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: lightBlue, accentColor: .blue)
    var healthkit = HealthKitService()

    @State private var hasLoaded = false
    var body: some View {
        Text("Personalize CyMe measuring and reporting")
       .font(.title)
       .fontWeight(.bold)
       .padding()
       .frame(maxWidth: .infinity, alignment: .leading)
       .background(theme.primaryColor.toColor())
    
        Form {
            Section(header: Text("Health Data Access")) {
                Toggle("Allow access to Apple Health", isOn: $settingsViewModel.settings.enableHealthKit)
                    .onChange(of: settingsViewModel.settings.enableHealthKit) { newValue in
                            if newValue {
                                healthkit.requestAuthorization()
                            } else {
                                for index in settingsViewModel.settings.healthDataSettings.indices {
                                    settingsViewModel.settings.healthDataSettings[index].enableDataSync = false
                                }
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
                        if (healthData.name != "menstruationStart"){
                            self.measurementRow(
                                label: healthData.label,
                                measure: $settingsViewModel.settings.healthDataSettings[index].enableDataSync,
                                selfReport: $settingsViewModel.settings.healthDataSettings[index].enableSelfReportingCyMe,
                                dataLocation: settingsViewModel.settings.healthDataSettings[index].dataLocation,
                                isHealthKitEnabled: settingsViewModel.settings.enableHealthKit
                            )
                        }
                    }
                }
            }
        }
        

        Button(action: {
            if hasMenstruationData() {
                settingsViewModel.settings.healthDataSettings[1].enableSelfReportingCyMe = settingsViewModel.settings.healthDataSettings[0].enableSelfReportingCyMe
                settingsViewModel.settings.healthDataSettings[1].enableDataSync = settingsViewModel.settings.healthDataSettings[0].enableDataSync
                nextPage()
            }
        }
        ) {
            Text("Continue")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                .background(hasMenstruationData() ? theme.accentColor.toColor() : Color.gray)
        }
    }
    
    func hasMenstruationData() -> Bool {
        return settingsViewModel.settings.healthDataSettings[0].enableSelfReportingCyMe || settingsViewModel.settings.healthDataSettings[0].enableDataSync
    }
       

    func measurementRow(label: String, measure: Binding<Bool>, selfReport: Binding<Bool>, dataLocation: DataLocation, isHealthKitEnabled: Bool) -> some View {
        HStack {
            Text(label)
                .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            Toggle("", isOn: measure)
                .labelsHidden()
                .frame(width: 100, alignment: .center)
                .disabled(!isHealthKitEnabled || dataLocation == .onlyCyMe )
            
            Spacer()
            
            Toggle("", isOn: selfReport)
                .labelsHidden()
                .frame(width: 100, alignment: .center)
                .disabled(dataLocation == .onlyAppleHealth)
        }
    }


}

struct PersonalizationView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalizationView(nextPage: {}, settingsViewModel: SettingsViewModel(connector: WatchConnector()))
    }
}
