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

    var body: some View {
        VStack {
            HStack {
                Text("Min: \(symptom.min)")
                Text("Max: \(symptom.max)")
                Text("Average: \(symptom.average)")
            }
            Text("Covariance: \(String(format: "%.2f", symptom.covariance))")
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
            min: 2,
            max: 10,
            average: 5,
            covariance: 2.5,
            covarianceOverview: [
                [2, 3, 4, 6, 5],
                [1, 2, 3, 4, 5]
            ],
            questionType: .painEmoticonRating
        ))
    }
}
