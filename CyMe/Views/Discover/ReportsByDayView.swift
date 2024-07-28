//
//  ReportsByDayView.swift
//  CyMe
//
//  Created by Marinja Principe on 28.07.2024.
//

import SwiftUI

struct ReportsByDayView: View {
    var reportsByDay: [Date: [ReviewReportModel]]
    @Binding var selectedDate: Date

    var body: some View {
        VStack {
            HStack {
                Button(action: previousDay) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .labelsHidden()
                Spacer()
                Button(action: nextDay) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()

            if let reports = reportsByDay[Calendar.current.startOfDay(for: selectedDate)] {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(reports) { report in
                            ReviewReportView(report: report)
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                    }
                    .padding()
                }
            } else {
                Text("No reports available for this date")
                    .font(.headline)
                    .padding()
            }
        }
    }

    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func previousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }

    private func nextDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}








