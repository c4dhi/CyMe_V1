//
//  FilterView.swift
//  CyMe
//
//  Created by Marinja Principe on 05.06.24.
//

import SwiftUI

struct SymptomFilterView: View {
    var symptoms: [SymptomModel]
    @Binding var selectedSymptoms: Set<SymptomModel>
    @Binding var showingFilterSheet : Bool
    @State private var theme: ThemeModel = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: lightBlue, accentColor: .blue)

    var body: some View {
        NavigationView {
            List {
                ForEach(symptoms, id: \.id) { symptom in
                    HStack {
                        Text(symptom.title)
                        Spacer()
                        if selectedSymptoms.contains(symptom) {
                            Image(systemName: "checkmark")
                                .foregroundColor(theme.primaryColor.toColor())
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedSymptoms.contains(symptom) {
                            selectedSymptoms.remove(symptom)
                        } else {
                            selectedSymptoms.insert(symptom)
                        }
                    }
                }
            }
            .navigationTitle("Select Symptoms")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        showingFilterSheet = false
                    }
                }
            }
        }
    }
}


struct SymptomFilterView_Previews: PreviewProvider {
    static var previews: some View {
        SymptomFilterView(symptoms: [
            SymptomModel(
                title: "Example Symptom Filter View",
                dateRange: [],
                cycleOverview: [0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1, 0, 1, 2, 3, 2, 1],
                hints: ["Most frequent in period phase"],
                min: "0",
                max: "3",
                average: "1",
                covariance: 2.5,
                correlationOverview: [[2, 3, 4, 6, 5], [1, 2, 3, 4, 5]],
                questionType: .painEmoticonRating
            )
        ], selectedSymptoms: .constant([]), showingFilterSheet: .constant(true))
    }
}
