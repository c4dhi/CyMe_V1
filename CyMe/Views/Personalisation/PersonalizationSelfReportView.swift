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
    @Binding var frequencyIndex: Int
    @Binding var timesPerDay: [Date]
    @Binding var startDate: Date
    
    let frequencyOptions = ["Each Day", "Each Second Day", "Once a Week", "Each Hour", "Multiple Times per Day"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(title, isOn: $isEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .blue)) // Apply a consistent toggle style
            
            if isEnabled {
                Picker("Frequency", selection: $frequencyIndex) {
                    ForEach(0..<frequencyOptions.count, id: \.self) { index in
                        Text(frequencyOptions[index])
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Use a menu picker style for better consistency
                .padding(.horizontal)
                
                DatePicker("Start Date", selection: $startDate, in: Date()..., displayedComponents: .date)
                    .padding(.horizontal)
                
                if frequencyIndex == 4 { // Multiple Times per Day
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
                        .padding(.horizontal)
                    }
                    Button(action: {
                        timesPerDay.append(Date())
                    }) {
                        Label("Add Time", systemImage: "plus")
                    }
                    .padding(.horizontal)
                } else {
                    TimePicker(title: "Time", time: $timesPerDay[0])
                        .padding(.horizontal)
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
    @State private var enableWatchReporting = false
    
    @State private var startPeriodEnabled = false
    @State private var startPeriodFrequency = 0
    @State private var startPeriodTimes: [Date] = [Date()]
    @State private var startPeriodStartDate = Date()
    
    @State private var selfReportEnabled = false
    @State private var selfReportFrequency = 0
    @State private var selfReportTimes: [Date] = [Date()]
    @State private var selfReportStartDate = Date()
    
    @State private var dailySummaryEnabled = false
    @State private var dailySummaryFrequency = 0
    @State private var dailySummaryTimes: [Date] = [Date()]
    @State private var dailySummaryStartDate = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Personalize CyMe reminders")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            // Enable self-reporting on Apple Watch
            Toggle("Enable self-reporting on Apple watch", isOn: $enableWatchReporting)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            ReminderOptionView(title: "Start period", isEnabled: $startPeriodEnabled, frequencyIndex: $startPeriodFrequency, timesPerDay: $startPeriodTimes, startDate: $startPeriodStartDate)
            
            ReminderOptionView(title: "Time to self-report", isEnabled: $selfReportEnabled, frequencyIndex: $selfReportFrequency, timesPerDay: $selfReportTimes, startDate: $selfReportStartDate)
            
            ReminderOptionView(title: "Daily summary", isEnabled: $dailySummaryEnabled, frequencyIndex: $dailySummaryFrequency, timesPerDay: $dailySummaryTimes, startDate: $dailySummaryStartDate)
            
            
            Button(action: nextPage) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct PersonalizationSelfReportView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalizationSelfReportView(nextPage: {})
    }
}
