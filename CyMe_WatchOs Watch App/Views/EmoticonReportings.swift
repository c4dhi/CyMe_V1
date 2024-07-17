//
//  emotionalRatings.swift
//  CyMe_WatchOs Watch App
//
//  Created by Marinja Principe on 17.06.24.
//

//
//  emoticonReportings.swift
//  CyMe
//
//  Created by Marinja Principe on 12.06.24.
//

import SwiftUI


struct EmoticonRatingQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selectedOption : SymptomSelfReportModel?

    let emoticons: [(String, String)] = [
        ("😭", "Very bad"),
        ("😣", "Bad"),
        ("🤔", "Neutral"),
        ("😌", "Well"),
        ("🤩", "Very well")
    ]

    @State private var selectedEmoticon: String?

    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .font(.caption2)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 50)
            ScrollView(.horizontal) {
                HStack(alignment: .center) {
                    ForEach(emoticons, id: \.0) { (emoticon, description) in
                        VStack {
                            Button(action: {
                                selectedEmoticon = description
                                selectedOption = SymptomSelfReportModel(healthDataName: setting.name, healthDataLabel: setting.label, questionType: setting.questionType, reportedValue: description)
                            }) {
                                Text(emoticon)
                                    .font(.caption)
                                    .padding()
                                    .background(selectedEmoticon == description ? Color.blue : Color.clear)
                                    .foregroundColor(selectedEmoticon == description ? .white : .blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MenstruationEmoticonRatingQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selectedOption : SymptomSelfReportModel?

    let emoticons: [(String, String)] = [
        ("No", "No"),
        ("🩸", "Mild"),
        ("🩸🩸", "Moderate"),
        ("🩸🩸🩸", "Severe"),
    ]

    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .font(.caption2)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 50)
            ScrollView(.horizontal) {
                HStack(alignment: .center) {
                    ForEach(emoticons, id: \.0) { (emoticon, description) in
                        VStack {
                            Button(action: {
                                selectedOption = SymptomSelfReportModel(healthDataName: setting.name, healthDataLabel: setting.label, questionType: setting.questionType, reportedValue: description)
                            }) {
                                Text(emoticon)
                                    .font(.caption)
                                    .padding()
                                    .background(selectedOption?.reportedValue == description ? Color.blue : Color.clear)
                                    .foregroundColor(selectedOption?.reportedValue == description ? .white : .blue)
                                    .cornerRadius(8)
                            }
                        }
                        if emoticon == "No" {
                            Text("|")
                                .font(.title)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
    }
}

struct MenstruationStartRatingQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selectedOption: SymptomSelfReportModel?
    @State var isFirstDayOfPeriod = false


    var body: some View {
        VStack(alignment: .center) {
                Toggle(setting.question, isOn: $isFirstDayOfPeriod)
                    .padding(.bottom, 10)
                    .padding(.top, 50)
                    .padding(.horizontal)
                    .onAppear {
                        selectedOption = SymptomSelfReportModel(healthDataName: setting.name, healthDataLabel: setting.label, questionType: setting.questionType, reportedValue: String(isFirstDayOfPeriod))
                    }
                    .onChange(of: isFirstDayOfPeriod) { newValue in
                        selectedOption = SymptomSelfReportModel(healthDataName: setting.name, healthDataLabel: setting.label, questionType: setting.questionType, reportedValue: String(newValue))
                    }
            
        }
    }
}


struct PainEmoticonRatingQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selectedOption : SymptomSelfReportModel?

    let emoticons: [(String, String)] = [
        ("No", "No"),
        ("😐", "Mild"),
        ("😣", "Moderate"),
        ("😖", "Severe"),
    ]

    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .font(.caption2)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 50)
            ScrollView(.horizontal) {
                HStack(alignment: .center) {
                    ForEach(emoticons, id: \.0) { (emoticon, description) in
                        VStack {
                            Button(action: {
                                selectedOption = SymptomSelfReportModel(healthDataName: setting.name, healthDataLabel: setting.label, questionType: setting.questionType, reportedValue: description)
                            }) {
                                Text(emoticon)
                                    .font(.caption)
                                    .padding()
                                    .background(selectedOption?.reportedValue == description ? Color.blue : Color.clear)
                                    .foregroundColor(selectedOption?.reportedValue == description ? .white : .blue)
                                    .cornerRadius(8)
                            }
                        }
                        if emoticon == "No" {
                            Text("|")
                                .font(.title)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
    }
}

struct ChangeEmoticonRatingQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selectedOption : SymptomSelfReportModel?

    let emoticons: [(String, String)] = [
        ("No", "No"),
        ("⬇", "Less"),
        ("⬆", "More")
    ]

    @State private var selectedEmoticon: String?

    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .font(.caption2)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 50)
            HStack(alignment: .center) {
                    ForEach(emoticons, id: \.0) { (emoticon, description) in
                        VStack {
                            Button(action: {
                                selectedEmoticon = description
                                selectedOption = SymptomSelfReportModel(healthDataName: setting.name, healthDataLabel: setting.label, questionType: setting.questionType, reportedValue: description)
                            }) {
                                Text(emoticon)
                                    .font(.caption)
                                    .padding()
                                    .background(selectedEmoticon == description ? Color.blue : Color.clear)
                                    .foregroundColor(selectedEmoticon == description ? .white : .blue)
                                    .cornerRadius(8)
                            }
                        }
                        if emoticon == "No" {
                            Text("|")
                                .font(.title)
                                .foregroundColor(.primary)
                        }
                    }
                }
            
        }
    }
}

struct AmountOfHourQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selectedOption : SymptomSelfReportModel?
    
    @State private var selectedHours = 7
    @State private var selectedMinutes = 0
    
    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .font(.caption2)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 50)
            
            HStack {
                Picker("Hours", selection: $selectedHours) {
                    ForEach(0..<24) { hour in
                        Text("\(hour)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 80)
                
                Text("hours")
                    .font(.caption2)
                
                Picker("Minutes", selection: $selectedMinutes) {
                    ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { minute in
                        Text("\(minute)").tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 80)
                
                Text("minutes")
                    .font(.caption2)
            }
            .padding()
        }
        .onAppear {
            updateSelectedOption()
        }
        .onChange(of: selectedHours) { newValue in
            updateSelectedOption()
        }
        .onChange(of: selectedMinutes) { newValue in
            updateSelectedOption()
        }
    }
    private func updateSelectedOption() {
        let reportedValue = "\(selectedHours) hours \(selectedMinutes) minutes"
        selectedOption = SymptomSelfReportModel(healthDataName: setting.name, healthDataLabel: setting.label, questionType: setting.questionType, reportedValue: reportedValue)
    }
}

struct OpenTextQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selectedOption : SymptomSelfReportModel?
    @State private var enteredText: String = ""

    var body: some View {
        VStack(alignment: .center) {
            Text("Is there something else you would like to add?")
                .font(.caption2)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 50)
            TextField("Enter text", text: $enteredText)
                .padding()
                .onChange(of: enteredText) { newText in
                    selectedOption = SymptomSelfReportModel(healthDataName: "notes", healthDataLabel: "Notes", questionType: .open, reportedValue: newText)
                }
        }
        .padding()
    }
}
