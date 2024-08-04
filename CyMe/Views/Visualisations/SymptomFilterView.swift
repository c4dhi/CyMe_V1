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
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        NavigationView {
            List {
                ForEach(symptoms, id: \.id) { symptom in
                    HStack {
                        Text(symptom.title)
                        Spacer()
                        if selectedSymptoms.contains(where: { $0.title == symptom.title }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(themeManager.theme.primaryColor.toColor())
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
            .navigationTitle("Select symptoms")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        showingFilterSheet = false
                    }
                    .foregroundColor(themeManager.theme.primaryColor.toColor())
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
                correlation: 2.5,
                correlationOverview: [[2, 3, 4, 6, 5], [1, 2, 3, 4, 5]],
                questionType: .painEmoticonRating
            )
        ], selectedSymptoms: .constant([]), showingFilterSheet: .constant(true))
    }
}
