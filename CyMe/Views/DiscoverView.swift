// DiscoverView.swift
// CyMe
//
// Created by Marinja Principe on 17.04.24.
//

import SwiftUI
import SigmaSwiftStatistics

struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State private var selectedSymptom: SymptomModel?
    @State private var theme: ThemeModel = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: lightBlue, accentColor: .blue)
    @State private var selectedCycleOption = 1 // 1 for "This Cycle", 0 for "Last Cycle"
    @State private var isShowingSelfReports = false
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 5) {
            Text("Discover")
                .font(.title)

            Picker("Select a symptom", selection: $selectedSymptom) {
                ForEach(viewModel.symptoms, id: \.title) { symptom in
                    Text(symptom.title).tag(symptom as SymptomModel?)
                }
                Text("Self-reports").tag(nil as SymptomModel?)
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedSymptom) { newValue in
                            isShowingSelfReports = (newValue == nil)
                        }
            
            Picker(selection: $selectedCycleOption, label: Text("")) {
                Text("Last cycle").tag(0)
                Text("Current cycle").tag(1)
                
            }
            .pickerStyle(SegmentedPickerStyle())
            
            if isShowingSelfReports {
               let groupedReports = groupReportsByDay(reports: viewModel.selfReports)
               ReportsByDayView(reportsByDay: groupedReports, selectedDate: $selectedDate)
                   .transition(.slide)
           }  else if let symptom = selectedSymptom {
                List {
                    // Symptom graph and Insights Section
                    Section(header: Text("Inisghts to \(selectedCycleOption == 0 ? "last cycle" : "current cycle" )").padding(.vertical, 8)) {
                        VStack {
                            Text("Symptom graph")
                                .font(.headline)
                                .padding(.bottom, 8)
                            SymptomGraph(symptom: symptom)
                                .frame(height: 200)
                                .padding()
                                .background(theme.backgroundColor.toColor())
                                .cornerRadius(10)
                            Text("CyMe insights")
                                .font(.headline)
                            SymptomInsightsView(hints: symptom.hints)
                                .padding()
                                .background(theme.backgroundColor.toColor())
                                .cornerRadius(10)
                        }
                    }
                    
                    // Statistics and Correlation Section
                    Section(header: Text("Insights over multiple cycles").padding(.vertical, 8)) {
                        VStack {
                            Text("Symptom intensity across cycles")
                                .font(.headline)
                                .padding(.bottom, 8)
                            MultiSymptomGraph(symptom: symptom, multiSymptomList: symptom.correlationOverview)
                                .frame(height: 200)
                                .padding()
                                .background(theme.backgroundColor.toColor())
                                .cornerRadius(10)
                            MultiGraphLegend(availableCycles: viewModel.availableCycles)
                            Text("CyMe insights across cycles")
                                .font(.headline)
                                .padding(.bottom, 8)
                            SymptomStatisticsView(symptom: symptom)
                                .padding()
                                .background(theme.backgroundColor.toColor())
                                .cornerRadius(10)

                            
                        }
                    }
                }
            } else {
                Text("No reports available")
                .foregroundColor(.gray)
                .font(.headline)
                .padding()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            Logger.shared.log("Discover view is shown")
            Task{
                await viewModel.updateSymptoms(settingsViewModel: settingsViewModel)
                selectedSymptom = viewModel.symptoms.first
            }
            selectedCycleOption = 1
        }
        .onChange(of: selectedCycleOption){ newValue in
            let rememberSelectedSymptom = selectedSymptom?.title
            Task{
                await viewModel.updateChoice(currentCycle: (selectedCycleOption == 1))
                if (viewModel.symptoms.count == 0){ // If there are no symptoms in the new but the old cycle
                    selectedSymptom = nil
                }
                for symptom in viewModel.symptoms{
                    if symptom.title == rememberSelectedSymptom{
                        selectedSymptom = symptom
                        break
                    }
                }
                
                
            }
        }
    }
    
    func groupReportsByDay(reports: [ReviewReportModel]) -> [Date: [ReviewReportModel]] {
            var groupedReports = [Date: [ReviewReportModel]]()
            let calendar = Calendar.current

            for report in reports {
                let startOfDay = calendar.startOfDay(for: report.startTime)
                if groupedReports[startOfDay] != nil {
                    groupedReports[startOfDay]?.append(report)
                } else {
                    groupedReports[startOfDay] = [report]
                }
            }

            return groupedReports
        }

}



struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = DiscoverViewModel()
        mockViewModel.symptoms = generateMockSymptoms()
        
        return DiscoverView(viewModel: mockViewModel, settingsViewModel: SettingsViewModel(connector: WatchConnector()))
    }
    
    static func generateMockSymptoms() -> [SymptomModel] {
        // Generate mock symptoms data
        let headacheModel = SymptomModel(
            title: "Headaches",
            dateRange: [],
            cycleOverview: [1, 2, nil, 3, 1, 2, 1],
            hints: ["Hint 1", "Hint 2"],
            min: "1",
            max: "3",
            average: "1.5",
            covariance: 0.7,
            correlationOverview: [],
            questionType: .painEmoticonRating
        )
        
        let abdominalCrampsModel = SymptomModel(
            title: "Abdominal Cramps",
            dateRange: [],
            cycleOverview: [2, 3, nil, 1, 2, 3, 1],
            hints: ["Hint 1", "Hint 2"],
            min: "1",
            max: "3",
            average: "2",
            covariance: 0.6,
            correlationOverview: [],
            questionType: .painEmoticonRating
        )
        
        let appetiteChangeModel = SymptomModel(
            title: "Appetite Change",
            dateRange: [],
            cycleOverview: [1, nil, 2, 1, nil, 1, 2],
            hints: ["Hint 1", "Hint 2"],
            min: "1",
            max: "2",
            average: "1.25",
            covariance: 0.5,
            correlationOverview: [],
            questionType: .changeEmoticonRating
        )
        
        return [headacheModel, abdominalCrampsModel, appetiteChangeModel]
    }
}

