//  PersonalizationSelfReportView.swift
//  CyMe
//
//  Created by Marinja Principe on 13.05.24.
//
import SwiftUI

struct PersonalizationSelfReportView: View {
    var nextPage: () -> Void
    
    @ObservedObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Text("Personalize CyMe reminders")
       .font(.title)
       .fontWeight(.bold)
       .padding()
       .frame(maxWidth: .infinity, alignment: .leading)
       .background(themeManager.theme.primaryColor.toColor())
        Form {
            Section(header: Text("Self-Reporting Settings")) {
                Text("CyMe allows you to connect your Apple Watch and conveniently self-report directly from your wrist")
            }
            
            Section(header: Text("Reminders")) {
                
                ReminderOptionView(
                    title: "Time to self-report",
                    isEnabled: $settingsViewModel.settings.selfReportReminder.isEnabled,
                    frequency: $settingsViewModel.settings.selfReportReminder.frequency,
                    timesPerDay: $settingsViewModel.settings.selfReportReminder.times,
                    startDate: $settingsViewModel.settings.selfReportReminder.startDate
                )
                
            }
        }
        .scrollContentBackground(.hidden)
        .background(themeManager.theme.backgroundColor.toColor())
        
        Button(action: nextPage) {
            Text("Continue")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(themeManager.theme.accentColor.toColor())
                .cornerRadius(10)
        }
        .background(themeManager.theme.backgroundColor.toColor())
    }
}

struct PersonalizationSelfReportView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalizationSelfReportView(nextPage: {}, settingsViewModel: SettingsViewModel(connector: WatchConnector()))
    }
}


struct ReminderOptionView: View {
    var title: String
    @Binding var isEnabled: Bool
    @Binding var frequency: String
    @Binding var timesPerDay: [Date]
    @Binding var startDate: Date
    
    let frequencyOptions = ["Each day", "Each second day", "Once a week", "Each hour", "Multiple times per day"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(title, isOn: $isEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            if isEnabled {
                Picker("Frequency", selection: $frequency) {
                    ForEach(frequencyOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                DatePicker("Start date", selection: $startDate, in: Date()..., displayedComponents: .date)
                
                if frequency == "Multiple times per day" {
                    ForEach(0..<timesPerDay.count, id: \.self) { index in
                            TimePickerWithRemoveButton(title: "Time \(index + 1)", time: $timesPerDay[index], index: index, timesPerDay: $timesPerDay)
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
        .padding(.horizontal)
        .onChange(of: frequency) { newFrequency in
            removeExtraTimes()
        }
        
    }
    
    
    private func removeExtraTimes() {
        timesPerDay.removeSubrange(1..<timesPerDay.count)
    }
}

struct TimePickerWithRemoveButton: View {
    var title: String
    @Binding var time: Date
    let index: Int
    @Binding var timesPerDay: [Date]
    
    var body: some View {
        HStack {
            TimePicker(title: title, time: $time)
            if index > 0 {
                // If the need arises, here one could add a remove button
            } else {
                Spacer()
            }
        }
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
