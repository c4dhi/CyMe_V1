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

    var body: some View {
        VStack(spacing: 5) {
            Button(action: {
                Task {
                    await viewModel.getSymptomes(relevantDataList: [.headache, .abdominalCramps, .lowerBackPain, .pelvicPain, .acne, .chestTightnessOrPain, .appetiteChange, .exerciseTime, .stepCount])
                }
                }) {
                   Text("Tap Me")
                       .font(.headline)
                       .foregroundColor(.white)
                       .padding()
                       .background(Color.blue)
                       .cornerRadius(10)
               }
            Text("Discover")
                .font(.title)

            Picker("Select a symptom", selection: $selectedSymptom) {
                ForEach(viewModel.symptoms, id: \.title) { symptom in
                    Text(symptom.title).tag(symptom as SymptomModel?)
                }
            }
            .pickerStyle(MenuPickerStyle())

            
            if let symptom = selectedSymptom {
                List {
                    Section(header: Text("Symptom Graph").padding(.vertical, 8)) {
                        SymptomGraph(symptom: symptom)
                            .frame(height: 200)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }


                    Section(header: Text("Insights").padding(.vertical, 8)) {
                        SymptomInsightsView(hints: symptom.hints)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }


                    Section(header: Text("Statistics").padding(.vertical, 8)) {
                        SymptomStatisticsView(symptom: symptom)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            if viewModel.symptoms.isEmpty {
                let exampleSymptoms = [
                    SymptomModel(
                        title: "Example Symptom",
                        dateRange: [],
                        cycleOverview: [0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1],
                        hints: ["Most frequent in period phase"],
                        min: "2",
                        max: "10",
                        average: "5",
                        covariance: 2.5,
                        covarianceOverview: [
                            [2, 3, 4, 6, 5],
                            [1, 2, 3, 4, 5]
                        ],
                        questionType: .painEmoticonRating
                    )
                ]
                viewModel.symptoms = exampleSymptoms
                selectedSymptom = exampleSymptoms.first
            }
        }
        
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView(viewModel: DiscoverViewModel())
    }
}
