//
//  MultiSymptomGraph.swift
//  CyMe
//
//  Created by Marinja Principe on 05.07.24.
//

import SwiftUI
import Charts

struct MultiSymptomGraph: View {
    var symptom: SymptomModel
    var multiSymptomList: [[Int?]]
    private let labels = ["Last Cycle", "Current Cycle"]

    var body: some View {
        ScrollView(.horizontal) {
            Chart {
                ForEach(0..<multiSymptomList.count, id: \.self) { index in
                    createLineAndPointMarks(for: multiSymptomList[index], seriesIndex: index)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom, values: Array(1...maxCycleDays()).map { Double($0) - 0.5 }) { value in
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
                AxisMarks(position: .leading, values: getAxisValues(questionType: symptom.questionType)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(centered: false) {
                        if let doubleValue = value.as(Double.self) {
                            Text(intensityToString(intensity: doubleValue, questionType: symptom.questionType))
                        }
                    }
                }
            }
            .frame(width: 940)
            .chartLegend(.hidden)
        }
    }

    private func maxCycleDays() -> Int {
        return multiSymptomList.map { $0.count }.max() ?? 0
    }

    @ChartContentBuilder
    private func createLineAndPointMarks(for cycleOverview: [Int?], seriesIndex: Int) -> some ChartContent {
        let chartData = toLineChartData(cycleOverview: cycleOverview)

        ForEach(chartData) { item in
            LineMark(
                x: .value("Cycle day", item.day),
                y: .value("Intensity", item.intensity)
            )
            .foregroundStyle(by: .value("Series", seriesIndex))
        }

        ForEach(chartData) { item in
            PointMark(
                x: .value("Cycle day", item.day),
                y: .value("Intensity", item.intensity)
            )
            .foregroundStyle(by: .value("Series", seriesIndex))
        }
    }
}

struct MultiSymptomGraph_Previews: PreviewProvider {
    static var previews: some View {
        let symptom = SymptomModel(
            title: "Example Symptom Graph",
            dateRange: [],
            cycleOverview: [1, 2, nil, 4, 3, 2, 1, nil, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
            hints: ["Most frequent in luteal phase"],
            min: "1",
            max: "4",
            average: "2",
            correlation: 1.8,
            correlationOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
            questionType: .amountOfhour
        )
        MultiSymptomGraph(symptom: symptom, multiSymptomList: [[1, 2, nil, 4, 3], [2, 3, 4, 3, 2]])
    }
}

func toLineChartData(cycleOverview: [Int?]) -> [LineChartData] {
    var lineChartData: [LineChartData] = []
    for (index, intensity) in cycleOverview.enumerated() {
        if let intensity = intensity {
            let data = LineChartData(day: index + 1, intensity: intensity)
            lineChartData.append(data)
        }
    }
    return lineChartData
}
