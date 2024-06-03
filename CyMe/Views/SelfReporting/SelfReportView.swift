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
        let filteredSettings = settingsViewModel.settings.healthDataSettings.filter { setting in
            return setting.question != nil && setting.dataLocation != .onlyAppleHealth && setting.questionType != nil
        }
        return filteredSettings.map { setting in
            HealthDataWithoutNilModel(
                title: setting.title,
                enableDataSync: setting.enableDataSync,
                enableSelfReportingCyMe: setting.enableSelfReportingCyMe,
                dataLocation: setting.dataLocation,
                question: setting.question ?? "",
                questionType: setting.questionType ?? .yesNo
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
                        case .yesNo:
                            YesNoQuestionView(setting: healthData, selfReport: $selfReports)
                        case .intensity:
                            IntensityQuestionView(setting: healthData, selfReport: $selfReports)
                        case .emoticonRating:
                            EmoticonRatingQuestionView(setting: healthData, selfReport: $selfReports)
                        case .frequency:
                            FrequencyQuestionView(setting: healthData, selfReport: $selfReports)
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


struct YesNoQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selfReport: [SelfReportModel]

    @State private var selectedOption: String?

    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .padding(.top, 50)
            HStack {
                Button(action: {
                    selectedOption = "Yes"
                }) {
                    Text("Yes")
                        .padding()
                        .background(selectedOption == "Yes" ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    selectedOption = "No"
                }) {
                    Text("No")
                        .padding()
                        .background(selectedOption == "No" ? Color.red : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
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
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(emoticons, id: \.0) { (emoticon, description) in
                        Button(action: {
                            selectedEmoticon = description
                            selfReport.append(SelfReportModel(healthDataTitle: setting.title, questionType: setting.questionType, reportedValue: description))
                        }) {
                            Text(emoticon)
                                .padding()
                                .font(.title)
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

struct FrequencyQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selfReport: [SelfReportModel]

    @State private var selectedFrequency: String = ""

    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .padding(.top, 50)
            TextField("Enter frequency", text: $selectedFrequency)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct AmountOfHourQuestionView: View {
    var setting: HealthDataWithoutNilModel
    @Binding var selfReport: [SelfReportModel]
    @State private var selectedHours: String = ""

    var body: some View {
        VStack(alignment: .center) {
            Text(setting.question)
                .padding(.top, 50)
            TextField("Enter hours", text: $selectedHours)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
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
