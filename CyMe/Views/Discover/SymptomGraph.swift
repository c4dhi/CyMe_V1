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
    @State private var theme: ThemeModel = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: .blue, accentColor: .blue)

    var body: some View {
        ScrollView(.horizontal) {
            Chart {
                let chartData = symptom.toLineChartData()
                ForEach(chartData) { item in
                    LineMark(
                        x: .value("Cycle Day", item.day),
                        y: .value("Hours", item.hours)
                    )
                    .foregroundStyle(theme.primaryColor.toColor())
                }
                
                ForEach(chartData) { item in
                    PointMark(
                        x: .value("Cycle Day", item.day),
                        y: .value("Hours", item.hours)
                    )
                    .foregroundStyle(theme.accentColor.toColor())
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
            cycleOverview: [1, 2, nil, 4, 3, 2, 1, nil, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
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

struct PointChartData: Identifiable {
    var id = UUID()
    var title: String
    var day: Int
    var intensity: Int
    var questionType: QuestionType
}

struct LineChartData: Identifiable {
    var id = UUID()
    var title: String
    var day: Int
    var hours: Int
    var questionType: QuestionType
}


extension SymptomModel {
    func toLineChartData() -> [LineChartData] {
        var lineChartData: [LineChartData] = []
        for (index, hour) in cycleOverview.enumerated() {
            if let hour = hour {
                let data = LineChartData(title: title, day: index + 1, hours: hour, questionType: self.questionType)
                lineChartData.append(data)
            }
        }
        return lineChartData
    }
}

