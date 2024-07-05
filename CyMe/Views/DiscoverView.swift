// DiscoverView.swift
// CyMe
//
// Created by Marinja Principe on 17.04.24.
//

import SwiftUI
import SigmaSwiftStatistics

struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @State private var selectedSymptom: SymptomModel?
    @State private var theme: ThemeModel = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: .blue, accentColor: .blue)
    @State private var selectedCycleOption = 1 // 1 for "This Cycle", 0 for "Last Cycle"

    var body: some View {
        VStack(spacing: 5) {
            Text("Discover")
                .font(.title)

            Picker("Select a symptom", selection: $selectedSymptom) {
                ForEach(viewModel.symptoms, id: \.title) { symptom in
                    Text(symptom.title).tag(symptom as SymptomModel?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            Picker(selection: $selectedCycleOption, label: Text("")) {
                Text("Last Cycle").tag(0)
                Text("This Cycle").tag(1)
                
            }
            .pickerStyle(SegmentedPickerStyle())
            
            

            
            if let symptom = selectedSymptom {
                List {
                    Section(header: Text("Symptom Graph").padding(.vertical, 8)) {
                        SymptomGraph(symptom: symptom)
                            .frame(height: 200)
                            .padding()
                            .background(theme.backgroundColor.toColor())
                            .cornerRadius(10)
                    }


                    Section(header: Text("Insights").padding(.vertical, 8)) {
                        SymptomInsightsView(hints: symptom.hints)
                            .padding()
                            .background(theme.backgroundColor.toColor())
                            .cornerRadius(10)
                    }


                    Section(header: Text("Statistics").padding(.vertical, 8)) {
                        SymptomStatisticsView(symptom: symptom)
                            .padding()
                            .background(theme.backgroundColor.toColor())
                            .cornerRadius(10)
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
            Task{
                await viewModel.updateSymptoms()
                selectedSymptom = viewModel.symptoms.first
            }
            selectedCycleOption = 1
        }
        .onChange(of: selectedCycleOption){ newValue in
            let rememberSelectedSymptom = selectedSymptom?.title
            Task{
                await viewModel.updateSymptoms(currentCycle: (selectedCycleOption == 1))
                
                for symptom in viewModel.symptoms{
                    if symptom.title == rememberSelectedSymptom{
                        selectedSymptom = symptom
                        break
                    }
                }
            }
        }
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = DiscoverViewModel()
        mockViewModel.symptoms = generateMockSymptoms()
        
        return DiscoverView(viewModel: mockViewModel)
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
            covarianceOverview: [],
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
            covarianceOverview: [],
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
            covarianceOverview: [],
            questionType: .changeEmoticonRating
        )
        
        return [headacheModel, abdominalCrampsModel, appetiteChangeModel]
    }
}
