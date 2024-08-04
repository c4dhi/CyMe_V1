//  OverviewTable.swift
//  CyMe
//
//  Created by Marinja Principe on 03.07.24.
//

import SwiftUI

struct OverviewTable: View {
    var symptoms: [SymptomModel]
    var count = 1
    
    private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter
        }
    
    var body: some View {
        ScrollView(.vertical){
            ScrollView(.horizontal){
                VStack(alignment: .leading) {
                    HStack {
                        Text("Cycle start at \(dateFormatter.string(from: symptoms[0].dateRange[0]))")
                            .font(.headline)
                            .padding(.bottom, 5)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Cycle day").frame(width: 100)
                        ForEach(1..<maxCycleDays()+1, id: \.self) { day in
                            Text("\(day)")
                                .frame(minWidth: 30)
                                .frame(maxWidth: .infinity)
                                .font(.caption)
                        }
                    }
                    .padding()
                    Divider().background(Color.gray)
                    
                    // Rows for each symptom
                    ForEach(Array(symptoms.enumerated()), id: \.element.id) { (index, symptom) in
                        HStack {
                            Text(symptom.title)
                                .frame(minWidth: 110)
                                .font(.caption)
                            
                            ForEach(1..<maxCycleDays()+1, id: \.self) { day in
                                if let intensity = symptom.cycleOverview[day-1] {
                                    getSymbol(for: symptom.questionType, intensity: intensity)
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("-")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding()
                        Divider().background(Color.gray)
                    }
                }
                .padding()
            }
        }
    }
    private func maxCycleDays() -> Int {
        return symptoms.map { $0.cycleOverview.count }.max() ?? 0
    }
    
    private func getSymbol(for questionType: QuestionType, intensity: Int) -> AnyView {
        switch questionType {
        case .emoticonRating:
            return AnyView(
                EmoticonSymbol(emotion: intensity)
            )
        case .painEmoticonRating:
            return AnyView(
                PainEmoticonSymbol(emotion: intensity)
            )
        case .amountOfhour:
            return AnyView(
                Text("\(intensity)h")
                    .font(.system(size: 10))
                    .foregroundColor(.blue)
            )
        case .amountOfSteps:
            return AnyView(
                Text("\(intensity)")
                    .font(.system(size: 10))
                    .foregroundColor(.blue)
            )
        case .amountOfMin:
            return AnyView(
                Text("\(intensity)m")
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
    
    struct PainEmoticonSymbol: View {
        let emotion: Int

        let emoticons: [(String, String)] = [
            ("No", "No"),
            ("😐", "Mild"),
            ("😣", "Moderate"),
            ("😖", "Severe"),
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

struct OverviewTable_Previews: PreviewProvider {
    static var previews: some View {
        OverviewTable(symptoms: [
            SymptomModel(
                title: "Headache",
                dateRange: [],
                cycleOverview: [0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1],
                hints: ["Most frequent in period phase"],
                min: "0",
                max: "3",
                average: "1",
                correlation: 2.5,
                correlationOverview: [[2, 3, 4, 6, 5], [1, 2, 3, 4, 5]],
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
                correlation: 1.8,
                correlationOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
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
                correlation: 1.8,
                correlationOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
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
                correlation: 1.8,
                correlationOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
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
                correlation: 1.8,
                correlationOverview: [[1, 2, 3, 4, 3], [2, 3, 4, 3, 2]],
                questionType: .amountOfhour
            )
        ])
    }
}
