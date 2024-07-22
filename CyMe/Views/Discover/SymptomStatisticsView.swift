//
//  symptomStatisticsView.swift
//  CyMe
//
//  Created by Marinja Principe on 03.06.24.
//

// SymptomStatisticsView.swift
// CyMe
//
// Created by Marinja Principe on 03.06.24.
//

import SwiftUI

struct SymptomStatisticsView: View {
    var symptom: SymptomModel
    @State private var showingPopover = false

    var body: some View {
        VStack {
            Text("\(symptom.min)")
            Text("\(symptom.max)")
            Text("\(symptom.average)")
            HStack {
                Text("Correlation: \(String(format: "%.2f", symptom.covariance))")
                Button(action: {
                    showingPopover.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.blue)
                }
                .popover(isPresented: $showingPopover) {
                    VStack {
                        Text("Correlation Explanation")
                            .font(.headline)
                        Text("The correlation value indicates how strongly the symptoms are related to each other. A value closer to 1 means a strong positive correlation, while a value closer to -1 means a strong negative correlation. A value around 0 indicates no correlation.")
                            .padding()
                    }
                    .padding()
                }
            }
        }
    }
}

struct SymptomStatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        SymptomStatisticsView(symptom: SymptomModel(
            title: "Example Statistics View",
            dateRange: [],
            cycleOverview: [0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1],
            hints: ["Most frequent in period phase"],
            min: "2",
            max: "10",
            average: "5",
            covariance: 2.5,
            correlationOverview: [
                [2, 3, 4, 6, 5],
                [1, 2, 3, 4, 5]
            ],
            questionType: .painEmoticonRating
        ))
    }
}
