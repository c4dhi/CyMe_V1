//
//  VisualisationView.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//
import SwiftUI

struct VisualisationView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @State private var selectedSymptoms: Set<SymptomModel> = []
    @State private var showingFilterSheet = false
    @State private var theme: ThemeModel = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: .blue, accentColor: .blue)

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Visualization")
                    .font(.title)
                    .padding()
                Spacer()
            }
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showingFilterSheet.toggle()
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                            .padding()
                            .foregroundColor(theme.primaryColor.toColor())
                    }
                }
            }
            
            if selectedSymptoms.isEmpty {
                Text("No reports found")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding()
            } else {
                SymptomsMultiSelectView(selectedSymptoms: Array(selectedSymptoms))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            selectedSymptoms = Set(viewModel.symptoms)
        }
        .sheet(isPresented: $showingFilterSheet) {
            SymptomFilterView(symptoms: viewModel.symptoms, selectedSymptoms: $selectedSymptoms, showingFilterSheet: $showingFilterSheet)
        }
    }
}

struct VisualisationView_Previews: PreviewProvider {
    static var previews: some View {
        VisualisationView(viewModel: DiscoverViewModel())
    }
}
