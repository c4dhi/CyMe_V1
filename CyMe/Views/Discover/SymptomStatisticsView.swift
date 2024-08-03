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
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(symptom.min)")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(symptom.max)")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(symptom.average)")
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                let symptomCovariance = symptom.covariance == nil ? "" : String(format: "%.2f", symptom.covariance!)
                Text("Correlation: \(symptomCovariance)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(action: {
                    showingPopover.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(themeManager.theme.primaryColor.toColor())
                }
                .popover(isPresented: $showingPopover) {
                    VStack {
                        Text("Correlation Explanation")
                            .font(.headline)
                        Text("Correlation is a measure that expresses the extent to which your two displayed cycles change together. The closer to +1 your correlation value is, the more similar your health-metric-curves have been over the two displayed cycles.")
                            .padding()
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .environmentObject(ThemeManager())
    }
}
