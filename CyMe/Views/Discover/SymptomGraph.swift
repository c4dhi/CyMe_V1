//
//  SymptomGraph.swift
//  CyMe
//
//  Created by Marinja Principe on 03.06.24.
//

import SwiftUI
import Charts

struct SymptomGraph: View {
    var symptom: SymptomModel


    var body: some View {
        ScrollView(.horizontal) {
            Chart {
                ForEach(Array(symptom.toLineChartData().enumerated()), id: \.element.id) { (index, item) in
                    LineMark(
                        x: .value("Cycle Day", item.day),
                        y: .value("Hours", item.hours)
                    )
                    .foregroundStyle(.green)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom, values: Array(1...31).map { Double($0) - 0.5 }) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(centered: true) {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(centered: true) {
                        if let doubleValue = value.as(Double.self) {
                            Text(String(format: "%.1f", doubleValue))
                        }
                    }
                }
            }
            .frame(width: 940)
        }
    }
}

struct SymptomGraph_Previews: PreviewProvider {
    static var previews: some View {
        SymptomGraph(symptom: SymptomModel(
            title: "Example Symptom Graph",
            dateRange: [],
            cycleOverview: [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
            hints: ["Most frequent in luteal phase"],
            min: "1",
            max: "4",
            average: "2",
            covariance: 1.8,
            covarianceOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
            questionType: .amountOfhour
        ))
    }
}
