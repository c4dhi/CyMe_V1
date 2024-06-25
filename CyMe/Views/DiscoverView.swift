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
            selectedSymptom = viewModel.symptoms.first
        }
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView(viewModel: DiscoverViewModel())
    }
}
