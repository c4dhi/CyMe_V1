//
//  PersonalizationSelfReportView.swift
//  CyMe
//
//  Created by Marinja Principe on 13.05.24.
//
//
//  PersonalizationSelfReportView.swift
//  CyMe
//
//  Created by Marinja Principe on 13.05.24.
//
import SwiftUI

struct ReminderOptionView: View {
    var title: String
    @Binding var isEnabled: Bool
    @Binding var frequencyIndex: String
    @Binding var timesPerDay: [Date]
    @Binding var startDate: Date
    
    let frequencyOptions = ["Each day", "Each second day", "Once a week", "Each hour", "Multiple times per day"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(title, isOn: $isEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            if isEnabled {
                Picker("Frequency", selection: $frequencyIndex) {
                    ForEach(frequencyOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                DatePicker("Start date", selection: $startDate, in: Date()..., displayedComponents: .date)
                
                if frequencyIndex == "Multiple times per day" {
                    ForEach(0..<timesPerDay.count, id: \.self) { index in
                        HStack {
                            TimePicker(title: "Time \(index + 1)", time: $timesPerDay[index])
                            if index > 0 {
                                Button(action: {
                                    timesPerDay.remove(at: index)
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                            } else {
                                Spacer()
                            }
                        }
                    }
                    Button(action: {
                        timesPerDay.append(Date())
                    }) {
                        Label("Add time", systemImage: "plus")
                    }
                } else {
                    TimePicker(title: "Time", time: $timesPerDay[0])
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal) // Add horizontal padding to match the profile form
    }
}



struct TimePicker: View {
    var title: String
    @Binding var time: Date
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
        }
    }
}

struct PersonalizationSelfReportView: View {
    var nextPage: () -> Void
    
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State private var theme: ThemeModel = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: .black, accentColor: .blue)
    
    var body: some View {
        Text("Personalize CyMe reminders")
       .font(.title)
       .fontWeight(.bold)
       .padding()
       .frame(maxWidth: .infinity, alignment: .leading)
       .background(theme.primaryColor.toColor())
        Form {
            Section(header: Text("Self-Reporting Settings")) {
                Toggle("Enable self-reporting on Apple Watch", isOn: $settingsViewModel.settings.selfReportWithWatch)
            }
            
            Section(header: Text("Reminders")) {
                ReminderOptionView(
                    title: "Start period",
                    isEnabled: $settingsViewModel.settings.startPeriodReminder.isEnabled,
                    frequencyIndex: $settingsViewModel.settings.startPeriodReminder.frequency,
                    timesPerDay: $settingsViewModel.settings.startPeriodReminder.times,
                    startDate: $settingsViewModel.settings.startPeriodReminder.startDate
                )
                
                ReminderOptionView(
                    title: "Time to self-report",
                    isEnabled: $settingsViewModel.settings.selfReportReminder.isEnabled,
                    frequencyIndex: $settingsViewModel.settings.selfReportReminder.frequency,
                    timesPerDay: $settingsViewModel.settings.selfReportReminder.times,
                    startDate: $settingsViewModel.settings.selfReportReminder.startDate
                )
                
                ReminderOptionView(
                    title: "Daily summary",
                    isEnabled: $settingsViewModel.settings.summaryReminder.isEnabled,
                    frequencyIndex: $settingsViewModel.settings.summaryReminder.frequency,
                    timesPerDay: $settingsViewModel.settings.summaryReminder.times,
                    startDate: $settingsViewModel.settings.summaryReminder.startDate
                )
            }
        }
        Button(action: nextPage) {
            Text("Continue")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(theme.accentColor.toColor())
                .cornerRadius(10)
        }
    }
}

struct PersonalizationSelfReportView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalizationSelfReportView(nextPage: {}, settingsViewModel: SettingsViewModel())
    }
}
