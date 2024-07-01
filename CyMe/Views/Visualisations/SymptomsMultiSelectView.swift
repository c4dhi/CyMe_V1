//
//  SymptomsMultiSelectView.swift
//  CyMe
//
//  Created by Marinja Principe on 05.06.24.
//

import SwiftUI
import Charts

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
    func toPointChartData() -> [PointChartData] {
        var pointChartData: [PointChartData] = []
        for (index, intensity) in cycleOverview.enumerated() {
            let data = PointChartData(title: title, day: index + 1, intensity: intensity ?? 0, questionType: self.questionType)
            pointChartData.append(data)
        }
        return pointChartData // TODO
    }
    func toLineChartData() -> [LineChartData] {
        var lineChartData: [LineChartData] = []
        for (index, hour) in cycleOverview.enumerated() {
                let data = LineChartData(title: title, day: index + 1, hours: hour ?? 0, questionType: self.questionType)
                lineChartData.append(data)
        }
        return lineChartData // TODO
    }
}

struct SymptomsMultiSelectView: View {
    let cycleDayWidth: CGFloat = 1000/30
    var selectedSymptoms: [SymptomModel]
    
    var pointChartData: [PointChartData] {
        var data: [PointChartData] = []
        for symptom in selectedSymptoms {
            data.append(contentsOf: symptom.toPointChartData())
        }
        return data
    }
    
    var lineChartData: [(LineChartData, Color)] {
        var data: [(LineChartData, Color)] = []
        let colors: [Color] = [.red, .blue, .green, .orange, .purple]
        for (index, symptom) in selectedSymptoms.enumerated() {
            let chartData = symptom.toLineChartData()
            let color = colors[index % colors.count]
            data.append(contentsOf: chartData.map { ($0, color) })
        }
        return data
    }


    
    var symptomTitles: [String] {
        selectedSymptoms.map { $0.title }
    }
    
    var body: some View {
        ScrollView(.vertical) {
            ScrollView(.horizontal) {
                HStack {
                    // Point chart
                    Chart {
                        ForEach(Array(selectedSymptoms.enumerated()), id: \.element.id) { (symptomIndex, symptom) in
                            ForEach(Array(symptom.toPointChartData().enumerated()), id: \.element.id) { (index, item) in
                                let symbol = getSymbol(for: item.questionType, intensity: item.intensity)
                                PointMark(
                                    x: .value("Cycle day", item.day),
                                    y: .value("Symptom", Double(symptomIndex))
                                )
                                .symbol {
                                    symbol
                                }
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks(position: .top, values: Array(1...31).map { Double($0) - 0.5 }) { value in
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
                    .chartXAxisLabel(position: .top, alignment: .leading) {
                        Text("Cycle day")
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let intValue = value.as(Int.self), intValue >= 0, intValue < symptomTitles.count {
                                    Text(symptomTitles[intValue])
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                    
                    .frame(width: 1000, height: CGFloat(selectedSymptoms.count * 40))
                    .overlay(
                        // mark good days
                        drawOverlay(cycleDay: 10, color: .green)
                    )
                    .overlay(
                        // mark bad days
                        drawOverlay(cycleDay: 3, color: .red)
                    )
                }
                // Line charts
                /*Chart {
                 ForEach(Array(selectedSymptoms.enumerated()), id: \.element.id) { (symptomIndex, symptom) in
                 ForEach(Array(symptom.toLineChartData().enumerated()), id: \.element.id) { (index, item) in
                 LineMark(
                 x: .value("Cycle Day", item.day),
                 y: .value("Hours", item.hours)
                 )
                 .foregroundStyle(.green)
                 }
                 }
                 }
                 .chartXAxis {
                 AxisMarks(position: .top, values: Array(1...31).map { Double($0) - 0.5 }) { value in
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
                 .frame(width: 940, height: CGFloat(selectedSymptoms.count * 40))
                 .padding(.leading, 50)
                 .padding(.top, 70)*/
            }
        }
    }
    
    func drawOverlay(cycleDay: Int, color: Color) -> some View {
        VStack {
            Rectangle()
                .fill(color.opacity(0.3))
                .frame(width: 30, height: CGFloat(selectedSymptoms.count * 40) + 700 + CGFloat(selectedSymptoms.count * 40))
                .offset(x: 0 -  CGFloat((14-cycleDay) * 30))
            
        }
    }

    
    private func getSymbol(for questionType: QuestionType, intensity: Int) -> AnyView {
        switch questionType {
        case .emoticonRating:
            return AnyView(
                EmoticonSymbol(emotion: intensity)
            )
        case .amountOfhour:
            return AnyView(
                Text("\(intensity)h")
                    .font(.system(size: 10))
                    .foregroundColor(.blue)
            )
        case .menstruationEmoticonRating:
            return AnyView(
                Circle()
                    .fill(color(for: intensity, color: Color.red))
                    .frame(width: circleSize(for: intensity), height: circleSize(for: intensity))
            )
        default:
            return AnyView(
                Circle()
                    .fill(color(for: intensity, color: Color.blue))
                    .frame(width: circleSize(for: intensity), height: circleSize(for: intensity))
            )
        }
    }
    
    private func circleSize(for intensity: Int) -> CGFloat {
        switch intensity {
        case 1:
            return 6
        case 2:
            return 12
        case 3:
            return 18
        default:
            return 0
        }
    }
    
    private func color(for intensity: Int, color: Color) -> Color {
        switch intensity {
        case 1:
            return color.opacity(0.5)
        case 2:
            return color.opacity(0.7)
        case 3:
            return color.opacity(1.0)
        default:
            return Color.clear
        }
    }
    
    struct EmoticonSymbol: View {
        let emotion: Int

        let emoticons: [(String, String)] = [
            ("😭", "Very Sad"),
            ("😣", "Sad"),
            ("🤔", "Neutral"),
            ("😌", "Happy"),
            ("🤩", "Very Happy")
        ]

        var body: some View {
            if 0..<emoticons.count ~= emotion {
                let (emoticon, _) = emoticons[emotion]
                return Text(emoticon)
                    .font(.system(size: 18))
            } else {
                return Text("")
            }
        }
    }
}

struct SymptomsMultiSelectView_Previews: PreviewProvider {
    static var previews: some View {
        SymptomsMultiSelectView(selectedSymptoms: [
            SymptomModel(
                title: "Headache",
                dateRange: [],
                cycleOverview: [0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1],
                hints: ["Most frequent in period phase"],
                min: "0",
                max: "3",
                average: "1",
                covariance: 2.5,
                covarianceOverview: [[2, 3, 4, 6, 5], [1, 2, 3, 4, 5]],
                questionType: .painEmoticonRating
            ),
            SymptomModel(
                title: "Fatigue",
                dateRange: [],
                cycleOverview: [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
                hints: ["Most frequent in luteal phase"],
                min: "1",
                max: "4",
                average: "2",
                covariance: 1.8,
                covarianceOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
                questionType: .painEmoticonRating
            ),
            SymptomModel(
                title: "Menstruation",
                dateRange: [],
                cycleOverview: [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
                hints: ["Most frequent in luteal phase"],
                min: "1",
                max: "4",
                average: "2",
                covariance: 1.8,
                covarianceOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
                questionType: .menstruationEmoticonRating
            ),
            SymptomModel(
                title: "Mood",
                dateRange: [],
                cycleOverview: [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
                hints: ["Most frequent in luteal phase"],
                min: "1",
                max: "4",
                average: "2",
                covariance: 1.8,
                covarianceOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
                questionType: .emoticonRating
            ),
            SymptomModel(
                title: "Sleep",
                dateRange: [],
                cycleOverview: [1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2, 1, 2, 3, 4, 3, 2],
                hints: ["Most frequent in luteal phase"],
                min: "1",
                max: "4",
                average: "2",
                covariance: 1.8,
                covarianceOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
                questionType: .amountOfhour
            )
        ])
    }
}
