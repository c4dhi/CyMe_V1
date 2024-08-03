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
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
            ScrollView(.horizontal) {
                Chart {
                    let chartData = symptom.toLineChartData()
                    ForEach(chartData) { item in
                        LineMark(
                            x: .value("Cycle day", item.day),
                            y: .value("Intensity", item.intensity )
                        )
                        .foregroundStyle(themeManager.theme.primaryColor.toColor())
                    }
                    
                    ForEach(chartData) { item in
                        PointMark(
                            x: .value("Cycle day", item.day),
                            y: .value("Intensity", item.intensity)
                        )
                        .foregroundStyle(themeManager.theme.primaryColor.toColor())
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom, values: Array(1...symptom.cycleOverview.count).map { Double($0) - 0.5 }) { value in
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
            }
    }
    
}

struct SymptomGraph_Previews: PreviewProvider {
    static var previews: some View {
        SymptomGraph(symptom: SymptomModel(
            title: "Example Symptom Graph",
            dateRange: [],
            cycleOverview: [1, 2, nil, 4, 3, 2, 1, nil, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
            hints: ["Most frequent in luteal phase"],
            min: "1",
            max: "4",
            average: "2",
            covariance: 1.8,
            correlationOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
            questionType: .amountOfhour
        ))
    }
}

struct PointChartData: Identifiable {
    var id = UUID()
    var day: Int
    var intensity: Int
}

struct LineChartData: Identifiable {
    var id = UUID()
    var day: Int
    var intensity: Int
}


extension SymptomModel {
    func toLineChartData() -> [LineChartData] {
        var lineChartData: [LineChartData] = []
        for (index, intensity) in cycleOverview.enumerated() {
            if let intensity = intensity {
                let data = LineChartData( day: index + 1, intensity: intensity)
                lineChartData.append(data)
            }
        }
        return lineChartData
    }
}

