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
    
    @StateObject private var selfReportViewModel: SelfReportViewModel
    @State private var selectedOption: SymptomSelfReportModel? = nil
    @State var selfReports: [SymptomSelfReportModel] = []
    @State var isLoading = false
    @State private var currentQuestionIndex: Int = 0
    var startTime = Date()

    init(settingsViewModel: SettingsViewModel, isPresented: Binding<Bool>) {
        self.settingsViewModel = settingsViewModel
        self._isPresented = isPresented
        _selfReportViewModel = StateObject(wrappedValue: SelfReportViewModel(settingsViewModel: settingsViewModel))
    }

    var filteredHealthData: [HealthDataWithoutNilModel] {
        var filteredSettings = settingsViewModel.settings.healthDataSettings.filter { setting in
            return setting.question != nil && setting.dataLocation != .onlyAppleHealth && setting.questionType != nil && setting.enableSelfReportingCyMe == true
        }
        filteredSettings.append(HealthDataSettingsModel(
            name: "Open Question",
            label: "Open Question",
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
                            MenstruationEmoticonRatingQuestionView(setting: healthData, selectedOption: $selectedOption)
                        case .menstruationStartRating:
                            MenstruationStartRatingQuestionView(setting: healthData, selectedOption: $selectedOption)
                        case .painEmoticonRating:
                            PainEmoticonRatingQuestionView(setting: healthData,selectedOption: $selectedOption)
                        case .changeEmoticonRating:
                            ChangeEmoticonRatingQuestionView(setting: healthData, selectedOption: $selectedOption)
                        case .amountOfhour:
                            AmountOfHourQuestionView(setting: healthData, selectedOption: $selectedOption)
                        case .open:
                            OpenTextQuestionView(setting: healthData, selectedOption: $selectedOption)
                        default:
                            PainEmoticonRatingQuestionView(setting: healthData, selectedOption: $selectedOption)
                        }
                    }

                    Spacer()

                    HStack {
                        Button(action: {
                            if currentQuestionIndex > 0 {
                                currentQuestionIndex -= 1
                                selectedOption = selfReports.popLast()
                            }
                        }) {
                            Text("Back")
                        }
                        .padding()
                        .disabled(currentQuestionIndex == 0)

                        Spacer()
                        Button(action: {
                            if shouldJumpOver() {
                                currentQuestionIndex += 1
                            }
                            onSkip()
                        }) {
                            Text("Skip")
                        }
                        .padding()

                        Button(action: {
                            if shouldJumpOver() {
                                currentQuestionIndex += 1
                            }
                            if currentQuestionIndex < filteredHealthData.count - 1 {
                                onNext()
                            } else {
                                submitSelfReport()
                            }
                        }) {
                            Text(currentQuestionIndex < filteredHealthData.count - 1 ? "Next" : "Submit")
                        }
                        .padding()
                        .disabled(selectedOption == nil && filteredHealthData[currentQuestionIndex].questionType != .open)
                    }

                    ProgressView(value: Double(currentQuestionIndex + 1), total: Double(filteredHealthData.count))
                        .padding()
                        .accentColor(.blue)
                }
                .navigationTitle("CyMe self-reporting")
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
    
    func shouldJumpOver() -> Bool {
        let currentQuestion = filteredHealthData[currentQuestionIndex]
        let lastReport = selectedOption
        
        // handle skip
        if currentQuestion.questionType == .menstruationEmoticonRating && (lastReport == nil)  {
            return true
            
        }
                                                                           
         // handle next and skip
        if currentQuestion.questionType == .menstruationEmoticonRating && lastReport?.questionType == .menstruationEmoticonRating && (lastReport?.reportedValue == "No" || lastReport?.reportedValue == nil) {
            return true
        }
        return false
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
            submitSelfReport()
            
        }
    }

    func submitSelfReport() {
        if let option = selectedOption {
            selfReports.append(option)
        }
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            Task{
                let success = await selfReportViewModel.saveReport(selfReports: selfReports, startTime: startTime)
                
                DispatchQueue.main.async {
                    isLoading = false
                    if success {
                        isPresented = false
                        Logger.shared.log("Report saved successfully!")
                    } else {
                        Logger.shared.log("Failed to save the report.")
                    }
                }
            }
        }
    }
}



struct SelfReportView_Previews: PreviewProvider {
    static var previews: some View {
        let connector = WatchConnector()
        let settingsViewModel = SettingsViewModel(connector: connector)
        return SelfReportView(settingsViewModel: settingsViewModel, isPresented: .constant(true))
    }
}
