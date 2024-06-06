//
//  SelfReportinView.swift
//  CyMe
//
//  Created by Marinja Principe on 15.05.24.
//

import SwiftUI

struct SelfReportView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Binding var isPresented: Bool

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
            question: "Do you have something else to mention?",
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
                        case .changeEmoticonRating:
                            ChangeEmoticonRatingQuestionView(setting: healthData, selfReport: $selfReports)
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
                        }
                        .padding()
                        .disabled(currentQuestionIndex == 0)

                        Spacer()
                        Button(action: {
                            currentQuestionIndex += 1
                        }) {
                            Text("Skip")
                        }
                        .padding()

                        Button(action: {
                            if currentQuestionIndex < filteredHealthData.count - 1 {
                                currentQuestionIndex += 1
                            } else {
                                submitSelfReport()
                            }
                        }) {
                            Text(currentQuestionIndex < filteredHealthData.count - 1 ? "Next" : "Submit")
                        }
                        .padding()
                    }

                    ProgressView(value: Double(currentQuestionIndex + 1), total: Double(filteredHealthData.count))
                        .padding()
                        .accentColor(.blue)
                }
                .navigationTitle("CyMe Self-Reporting")
                .navigationBarTitleDisplayMode(.inline)
                .font(.title2)
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
                isPresented = false
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
                .padding(.top, 50)
            HStack {
                ForEach(["No", "Mild", "Moderate", "Severe"], id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                        selfReport.append(SelfReportModel(healthDataTitle: setting.title, questionType: setting.questionType, reportedValue: option))
                    }) {
                        Text(option)
                            .font(.caption)
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
                .padding(.top, 50)
            HStack(alignment: .center) {
                ForEach(emoticons, id: \.0) { (emoticon, description) in
                    VStack {
                        Button(action: {
                            selectedEmoticon = description
                            selfReport.append(SelfReportModel(healthDataTitle: setting.title, questionType: setting.questionType, reportedValue: description))
                        }) {
                            Text(emoticon)
                                .font(.title2)
                                .padding()
                                .background(selectedEmoticon == description ? Color.blue : Color.clear)
                                .foregroundColor(selectedEmoticon == description ? .white : .blue)
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
                .padding(.top, 50)
            HStack(alignment: .center) {
                ForEach(emoticons, id: \.0) { (emoticon, description) in
                    VStack {
                        Button(action: {
                            selectedEmoticon = description
                            selfReport.append(SelfReportModel(healthDataTitle: setting.title, questionType: setting.questionType, reportedValue: description))
                        }) {
                            Text(emoticon)
                                .font(.title2)
                                .padding()
                                .background(selectedEmoticon == description ? Color.blue : Color.clear)
                                .foregroundColor(selectedEmoticon == description ? .white : .blue)
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
                .padding(.top, 50)
            HStack(alignment: .center) {
                    ForEach(emoticons, id: \.0) { (emoticon, description) in
                        VStack {
                            Button(action: {
                                selectedEmoticon = description
                                selfReport.append(SelfReportModel(healthDataTitle: setting.title, questionType: setting.questionType, reportedValue: description))
                            }) {
                                Text(emoticon)
                                    .font(.title2)
                                    .padding()
                                    .background(selectedEmoticon == description ? Color.blue : Color.clear)
                                    .foregroundColor(selectedEmoticon == description ? .white : .blue)
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
    @Binding var selfReport: [SelfReportModel]

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
                                selectedEmoticon = description
                                selfReport.append(SelfReportModel(healthDataTitle: setting.title, questionType: setting.questionType, reportedValue: description))
                            }) {
                                Text(emoticon)
                                    .font(.title2)
                                    .padding()
                                    .background(selectedEmoticon == description ? Color.blue : Color.clear)
                                    .foregroundColor(selectedEmoticon == description ? .white : .blue)
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
    @Binding var selfReport: [SelfReportModel]
    
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
    }
}

struct OpenTextQuestionView: View {
    @Binding var selfReport: [SelfReportModel]
    @State private var enteredText: String = ""

    var body: some View {
        VStack(alignment: .center) {
            Text("Is there something else you would like to add?")
                .padding(.top, 50)
            TextField("Enter text", text: $enteredText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
}

struct SelfReportView_Previews: PreviewProvider {
    static var previews: some View {
        let settingsViewModel = SettingsViewModel()
        return SelfReportView(settingsViewModel: settingsViewModel, isPresented: .constant(true))
    }
}
