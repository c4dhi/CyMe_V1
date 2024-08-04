//
//  SelfReportinView.swift
//  CyMe
//
//  Created by Marinja Principe on 15.05.24.
//

import SwiftUI
import WatchKit

struct SelfReportWatchView: View {
    @Binding var isSelfReporting: Bool
    @ObservedObject var connector: iOSConnector

    @State private var selectedOption: SymptomSelfReportModel? = nil
    @State var selfReports: [SymptomSelfReportModel] = []
    @State private var currentQuestionIndex: Int = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSubmittedSuccessfully = false

    var startTime = Date()

    init(connector: iOSConnector, isSelfReporting: Binding<Bool>) {
        self.connector = connector
        self._isSelfReporting = isSelfReporting
    }

    var filteredHealthData: [HealthDataWithoutNilModel] {
        var filteredSettings = connector.settings.healthDataSettings.filter { setting in
            return setting.question != nil && setting.dataLocation != .onlyAppleHealth && setting.questionType != nil && setting.enableSelfReportingCyMe == true
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
        print("seetings",filteredSettings)
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
                            OpenTextQuestionView(setting: healthData, selectedOption: $selectedOption)
                        case .menstruationStartRating:
                            MenstruationStartRatingQuestionView(setting: healthData, selectedOption: $selectedOption)
                        default:
                            PainEmoticonRatingQuestionView(setting: healthData,selectedOption: $selectedOption)
                        
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
                            Image(systemName: "arrow.backward.circle")
                                .font(.caption)
                        }
                        .padding()
                        .disabled(currentQuestionIndex == 0)
                        .background( Color.clear)

                        Spacer()
                        Button(action: {
                            if shouldJumpOver() {
                                currentQuestionIndex += 1
                            }
                            onSkip()
                        }) {
                            Image(systemName: "forward.circle")
                                .font(.caption)
                        }
                        .padding()
                        .background( Color.clear)

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
            
            if connector.isLoading {
                Color.primary.opacity(0.7)
                ProgressView()
            }
        }
        .ignoresSafeArea()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(isSubmittedSuccessfully ? "Success" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"), action: {
                        self.isSelfReporting = false
                })
            )
        }
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
        let selfReportModel = createSelfReportModel(selfReports: selfReports, startTime: startTime)
        print(selfReports)
        connector.sendSelfReportDataToiOS(selfReport: selfReportModel) { success, message in
            DispatchQueue.main.async {
                self.isSubmittedSuccessfully = success
                self.alertMessage = message
                self.showAlert = true
            }
        }
    }
    private func createSelfReportModel(selfReports: [SymptomSelfReportModel], startTime: Date) -> SelfReportModel {
        let endTime = Date()
        let isCyMeSelfReport = true
        let selfReportMedium = selfReportMediumType.watchApp

        return SelfReportModel(
            id: nil,
            startTime: startTime,
            endTime: endTime,
            isCyMeSelfReport: isCyMeSelfReport,
            selfReportMedium: selfReportMedium,
            reports: selfReports
        )
    }
}



struct SelfReportWatchView_Previews: PreviewProvider {
    static var previews: some View {
        let connector = iOSConnector()
        return SelfReportWatchView(connector: connector, isSelfReporting: .constant(true))
    }
}
