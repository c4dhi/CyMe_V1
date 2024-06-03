//
//  SelfReportinView.swift
//  CyMe
//
//  Created by Marinja Principe on 15.05.24.
//

import SwiftUI
import SharedModels

struct SelfReportView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel

    @State var selfReports: [SelfReportModel] = []
    @State var isLoading = false
    @State private var currentQuestionIndex: Int = 0

    var filteredHealthData: [HealthDataWithoutNilModel] {
        var filteredSettings = settingsViewModel.settings.healthDataSettings.filter { setting in
            return setting.question != nil && setting.dataLocation != .onlyAppleHealth && setting.questionType != nil
        }
        filteredSettings.append(HealthDataSettingsModel(
            title: "Open Question",
            enableDataSync: false,
            enableSelfReportingCyMe: true,
            dataLocation: .onlyCyMe,
            question: nil,
            questionType: .open
        ))
        return filteredSettings.map { setting in
            HealthDataWithoutNilModel(
                title: setting.title,
                enableDataSync: setting.enableDataSync,
                enableSelfReportingCyMe: setting.enableSelfReportingCyMe,
                dataLocation: setting.dataLocation,
                question: setting.question ?? "",
                questionType: setting.questionType ?? .intensity
            )
        }
    }

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    if currentQuestionIndex < filteredHealthData.count {
                        let healthData = filteredHealthData[currentQuestionIndex]
                        switch healthData.questionType {
                        case .intensity:
                            IntensityQuestionView(setting: healthData, selfReport: $selfReports)
                        case .emoticonRating:
                            EmoticonRatingQuestionView(setting: healthData, selfReport: $selfReports)
                        case .menstruationEmoticonRating:
                            MenstruationEmoticonRatingQuestionView(setting: healthData, selfReport: $selfReports)
                        case .painEmoticonRating:
                            PainEmoticonRatingQuestionView(setting: healthData, selfReport: $selfReports)
                        case .amountOfhour:
                            AmountOfHourQuestionView(setting: healthData, selfReport: $selfReports)
                        case .open:
                            OpenTextQuestionView(selfReport: $selfReports)
                        }
                    }

                    Spacer()

                    HStack {
                        Button(action: {
                            if currentQuestionIndex > 0 {
                                currentQuestionIndex -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.caption)
                        }
                        .disabled(currentQuestionIndex == 0)

                        Spacer()
                        Button(action: {
                            currentQuestionIndex += 1
                        }) {
                            Text("Skip")
                                .font(.caption)
                        }

                        Button(action: {
                            if currentQuestionIndex < filteredHealthData.count - 1 {
                                currentQuestionIndex += 1
                            } else {
                                submitSelfReport()
                            }
                        }) {
                            Text(currentQuestionIndex < filteredHealthData.count - 1 ? "Next" : "Submit")
                                .font(.caption)
                        }
                    }

                    ProgressView(value: Double(currentQuestionIndex + 1), total: Double(filteredHealthData.count))
                        .padding()
                        .accentColor(.blue)
                }
                .navigationTitle("CyMe Self-Reporting")
                .navigationBarTitleDisplayMode(.inline)
                .font(.title3)
            }
            
            if isLoading {
                Color.primary.opacity(0.7)
                ProgressView()
            }
        }
        .ignoresSafeArea()
    }

    func onNext() {
        if currentQuestionIndex < filteredHealthData.count - 1 {
            currentQuestionIndex += 1
        }
    }

    func submitSelfReport() {
        isLoading = true
        Task {
            do {
                // Simulate a network request
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds delay
                isLoading = false
                // Handle successful submission
            } catch {
                isLoading = false
                print(error.localizedDescription)
            }
        }
    }
}


struct IntensityQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selfReport: [SelfReportModel]

    @State private var selectedOption: String?

    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .font(.caption)
            HStack {
                ForEach(["No", "Mild", "Moderate", "Severe"], id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                        selfReport.append(SelfReportModel(healthDataTitle: setting.title, questionType: setting.questionType, reportedValue: option))
                    }) {
                        Text(option)
                            .font(.caption2)
                            .padding()
                            .background(selectedOption == option ? Color.blue : Color.clear)
                            .foregroundColor(selectedOption == option ? .white : .blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct EmoticonRatingQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selfReport: [SelfReportModel]

    let emoticons: [(String, String)] = [
        ("😭", "Very Sad"),
        ("😣", "Sad"),
        ("🤔", "Neutral"),
        ("😌", "Happy"),
        ("🤩", "Very Happy")
    ]

    @State private var selectedEmoticon: String?

    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .font(.caption)
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(emoticons, id: \.0) { (emoticon, description) in
                        Button(action: {
                            selectedEmoticon = description
                            selfReport.append(SelfReportModel(healthDataTitle: setting.title, questionType: setting.questionType, reportedValue: description))
                        }) {
                            Text(emoticon)
                                .padding()
                                .font(.caption2)
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

struct MenstruationEmoticonRatingQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selfReport: [SelfReportModel]

    let emoticons: [(String, String)] = [
        ("No", "No"),
        ("🩸", "Mild"),
        ("🩸🩸", "Moderate"),
        ("🩸🩸🩸", "Severe"),
    ]

    @State private var selectedEmoticon: String?

    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .font(.caption)
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(emoticons, id: \.0) { (emoticon, description) in
                        Button(action: {
                            selectedEmoticon = description
                            selfReport.append(SelfReportModel(healthDataTitle: setting.title, questionType: setting.questionType, reportedValue: description))
                        }) {
                            Text(emoticon)
                                .padding()
                                .font(.caption2)
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

struct PainEmoticonRatingQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selfReport: [SelfReportModel]

    let emoticons: [(String, String)] = [
        ("No", "No"),
        ("😐", "Mild"),
        ("😣", "Moderate"),
        ("😖", "Severe"),
    ]

    @State private var selectedEmoticon: String?

    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .font(.caption)
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(emoticons, id: \.0) { (emoticon, description) in
                        Button(action: {
                            selectedEmoticon = description
                            selfReport.append(SelfReportModel(healthDataTitle: setting.title, questionType: setting.questionType, reportedValue: description))
                        }) {
                            Text(emoticon)
                                .padding()
                                .font(.caption2)
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

struct AmountOfHourQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selfReport: [SelfReportModel]
    
    @State private var selectedHours = 0
    @State private var selectedMinutes = 0
    
    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .font(.caption)
            
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
    }
}

struct OpenTextQuestionView: View {
    @Binding var selfReport: [SelfReportModel]
    @State private var enteredText: String = ""

    var body: some View {
        VStack(alignment: .center) {
            Text("Is there something else you would like to add?")
                .font(.caption)
            TextField("Enter text", text: $enteredText)
                .padding()
        }
        .padding()
    }
}

struct SelfReportView_Previews: PreviewProvider {
    static var previews: some View {
        let settingsViewModel = SettingsViewModel()
        return SelfReportView(settingsViewModel: settingsViewModel)
    }
}
