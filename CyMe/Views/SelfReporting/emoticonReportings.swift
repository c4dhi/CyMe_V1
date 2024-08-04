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
                .padding(.top, 50)
            HStack(alignment: .center) {
                ForEach(emoticons, id: \.0) { (emoticon, description) in
                    VStack {
                        Button(action: {
                            selectedOption = SymptomSelfReportModel(healthDataName: setting.name, healthDataLabel: setting.label, questionType: setting.questionType, reportedValue: description)
                        }) {
                            Text(emoticon)
                                .font(.title2)
                                .padding()
                                .background(selectedOption?.reportedValue == description ? Color.blue : Color.clear)
                                .foregroundColor(selectedOption?.reportedValue == description ? .white : .blue)
                                .cornerRadius(8)
                        }
                        Text(description)
                            .font(.footnote)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

struct MenstruationEmoticonRatingQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selectedOption: SymptomSelfReportModel?

    let emoticons: [(String, String)] = [
        ("No", "No"),
        ("🩸", "Mild"),
        ("🩸🩸", "Moderate"),
        ("🩸🩸🩸", "Severe"),
    ]

    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .padding(.top, 50)

            HStack(alignment: .center) {
                ForEach(emoticons, id: \.0) { (emoticon, description) in
                    VStack {
                        Button(action: {
                            selectedOption = SymptomSelfReportModel(healthDataName: setting.name, healthDataLabel: setting.label, questionType: setting.questionType, reportedValue: description)
                        }) {
                            Text(emoticon)
                                .font(.title2)
                                .padding()
                                .background(selectedOption?.reportedValue == description ? Color.blue : Color.clear)
                                .foregroundColor(selectedOption?.reportedValue == description ? .white : .blue)
                                .cornerRadius(8)
                        }
                        if description != "No" {
                            Text(description)
                                .font(.footnote)
                                .foregroundColor(.primary)
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

struct MenstruationStartRatingQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selectedOption: SymptomSelfReportModel?

    @State private var isFirstDayOfPeriod: Bool

    init(setting: HealthDataWithoutNilModel, selectedOption: Binding<SymptomSelfReportModel?>) {
        self.setting = setting
        self._selectedOption = selectedOption
        
        // Initialize isFirstDayOfPeriod based on selectedOption
        _isFirstDayOfPeriod = State(initialValue: selectedOption.wrappedValue?.reportedValue == "true")
    }


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
                .padding(.top, 50)
            HStack(alignment: .center) {
                ForEach(emoticons, id: \.0) { (emoticon, description) in
                    VStack {
                        Button(action: {
                            selectedOption = SymptomSelfReportModel(healthDataName: setting.name, healthDataLabel: setting.label, questionType: setting.questionType, reportedValue: description)
                        }) {
                            Text(emoticon)
                                .font(.title2)
                                .padding()
                                .background(selectedOption?.reportedValue == description ? Color.blue : Color.clear)
                                .foregroundColor(selectedOption?.reportedValue == description ? .white : .blue)
                                .cornerRadius(8)
                        }
                        if description != "No" {
                            Text(description)
                                .font(.footnote)
                                .foregroundColor(.primary)
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
                .padding(.top, 50)
            HStack(alignment: .center) {
                    ForEach(emoticons, id: \.0) { (emoticon, description) in
                        VStack {
                            Button(action: {
                                selectedOption = SymptomSelfReportModel(healthDataName: setting.name, healthDataLabel: setting.label, questionType: setting.questionType, reportedValue: description)
                            }) {
                                Text(emoticon)
                                    .font(.title2)
                                    .padding()
                                    .background(selectedOption?.reportedValue == description ? Color.blue : Color.clear)
                                    .foregroundColor(selectedOption?.reportedValue == description ? .white : .blue)
                                    .cornerRadius(8)
                            }
                            if description != "No" {
                                Text(description)
                                    .font(.footnote)
                                    .foregroundColor(.primary)
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
            
            HStack {
                Picker("Hours", selection: $selectedHours) {
                    ForEach(0..<24) { hour in
                        Text("\(hour)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 80)
                
                Text("hours")
                    .font(.caption)
                
                Picker("Minutes", selection: $selectedMinutes) {
                    ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { minute in
                        Text("\(minute)").tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 80)
                
                Text("minutes")
                    .font(.caption)
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
                .padding(.top, 50)
            TextField("Enter text", text: $enteredText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: enteredText) { newText in
                    selectedOption = SymptomSelfReportModel(healthDataName: "notes", healthDataLabel: "Notes", questionType: .open, reportedValue: newText)
                }
        }
        .padding()
    }
}
