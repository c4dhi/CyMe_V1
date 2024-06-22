//
//  SelfReportinView.swift
//  CyMe
//
//  Created by Marinja Principe on 15.05.24.
//

import SwiftUI

struct SelfReportWatchView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    @StateObject private var selfReportViewModel: SelfReportViewModel
    @State private var selectedOption: SymptomSelfReportModel? = nil
    @State var selfReports: [SymptomSelfReportModel] = []
    @State var isLoading = false
    @State private var currentQuestionIndex: Int = 0
    var startTime = Date()

    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
        _selfReportViewModel = StateObject(wrappedValue: SelfReportViewModel(settingsViewModel: settingsViewModel))
    }

    var filteredHealthData: [HealthDataWithoutNilModel] {
        var filteredSettings = settingsViewModel.settings.healthDataSettings.filter { setting in
            return setting.question != nil && setting.dataLocation != .onlyAppleHealth && setting.questionType != nil
        }
        filteredSettings.append(HealthDataSettingsModel(
            name: "Open Question",
            label: "OpenQuestion",
            enableDataSync: false,
            enableSelfReportingCyMe: true,
            dataLocation: .onlyCyMe,
            question: "Do you have something else to mention?",
            questionType: .open
        ))
        return filteredSettings.map { setting in
            HealthDataWithoutNilModel(
                name: setting.name,
                label: setting.label,
                enableDataSync: setting.enableDataSync,
                enableSelfReportingCyMe: setting.enableSelfReportingCyMe,
                dataLocation: setting.dataLocation,
                question: setting.question ?? "",
                questionType: setting.questionType ?? .painEmoticonRating)
        }
    }

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    if currentQuestionIndex < filteredHealthData.count {
                        let healthData = filteredHealthData[currentQuestionIndex]
                        switch healthData.questionType {
                        case .emoticonRating:
                            EmoticonRatingQuestionView(setting: healthData, selectedOption: $selectedOption)
                        case .menstruationEmoticonRating:
                            MenstruationEmoticonRatingQuestionView(setting: healthData,selectedOption: $selectedOption)
                        case .painEmoticonRating:
                            PainEmoticonRatingQuestionView(setting: healthData,selectedOption: $selectedOption)
                        case .changeEmoticonRating:
                            ChangeEmoticonRatingQuestionView(setting: healthData, selectedOption: $selectedOption)
                        case .amountOfhour:
                            AmountOfHourQuestionView(setting: healthData, selectedOption: $selectedOption)
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
                            Image(systemName: "arrow.backward.circle")
                                .font(.caption)
                        }
                        .padding()
                        .disabled(currentQuestionIndex == 0)
                        .background( Color.clear)

                        Spacer()
                        Button(action: {
                            currentQuestionIndex += 1
                        }) {
                            Image(systemName: "forward.circle")
                                .font(.caption)
                        }
                        .padding()
                        .background( Color.clear)

                        Button(action: {
                            if currentQuestionIndex < filteredHealthData.count - 1 {
                                onNext()
                            } else {
                                print("report: ", selfReports)
                                submitSelfReport(selfReports: selfReports)
                            }
                        }) {
                            Image(systemName: currentQuestionIndex < filteredHealthData.count - 1 ? "arrow.forward.circle" : "checkmark.circle")
                                .font(.caption)
                        }
                        .padding()
                        .disabled(selectedOption == nil && filteredHealthData[currentQuestionIndex].questionType != .open)
                        .background(Color.clear)
                    }

                    ProgressView(value: Double(currentQuestionIndex + 1), total: Double(filteredHealthData.count))
                        .padding()
                        .accentColor(.blue)
                }
            }
            
            if isLoading {
                Color.primary.opacity(0.7)
                ProgressView()
            }
        }
        .ignoresSafeArea()
    }

    func onNext() {
        if let option = selectedOption {
            selfReports.append(option)
            selectedOption = nil
            currentQuestionIndex += 1
        }
    }

    func onSkip() {
        let healthData = filteredHealthData[currentQuestionIndex]
        let skippedOption = SymptomSelfReportModel(healthDataName: healthData.name, healthDataLabel: healthData.label, questionType: healthData.questionType, reportedValue: nil)
        selfReports.append(skippedOption)
        selectedOption = nil
        if currentQuestionIndex < filteredHealthData.count - 1 {
            currentQuestionIndex += 1
        } else {
            submitSelfReport(selfReports: selfReports)
        }
    }

    func submitSelfReport(selfReports: [SymptomSelfReportModel]) {
        isLoading = true
        _ = selfReportViewModel.saveReport(selfReports: selfReports, startTime: startTime)
        isLoading = false
    }
}



struct SelfReportWatchView_Previews: PreviewProvider {
    static var previews: some View {
        let settingsViewModel = SettingsViewModel()
        return SelfReportWatchView(settingsViewModel: settingsViewModel)
    }
}
