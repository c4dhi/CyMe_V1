//
//  MultiSymptomGraph.swift
//  CyMe
//
//  Created by Marinja Principe on 05.07.24.
//

import SwiftUI
import Charts

struct MultiSymptomGraph: View {
    var multiSymptomList: [[Int?]]
    @State private var theme: ThemeModel = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: .blue, accentColor: .blue)

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

    private func maxCycleDays() -> Int {
        return multiSymptomList.map { $0.count }.max() ?? 0
    }

    @ChartContentBuilder
    private func createLineAndPointMarks(for cycleOverview: [Int?], seriesIndex: Int) -> some ChartContent {
        let chartData = toLineChartData(cycleOverview: cycleOverview)

        ForEach(chartData) { item in
            LineMark(
                x: .value("Cycle Day", item.day),
                y: .value("Intensity", item.intensity)
            )
            .foregroundStyle(by: .value("Series", seriesIndex))
        }

        ForEach(chartData) { item in
            PointMark(
                x: .value("Cycle Day", item.day),
                y: .value("Intensity", item.intensity)
            )
            .foregroundStyle(by: .value("Series", seriesIndex))
        }
    }
}

struct MultiSymptomGraph_Previews: PreviewProvider {
    static var previews: some View {
        MultiSymptomGraph(multiSymptomList: [[1, 2, nil, 4, 3], [2, 3, 4, 3, 2]])
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
