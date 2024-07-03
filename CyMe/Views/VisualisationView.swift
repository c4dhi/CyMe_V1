import SwiftUI

struct VisualisationView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @State private var selectedSymptoms: Set<SymptomModel> = []
    @State private var showingFilterSheet = false
    @State private var theme: ThemeModel = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: .blue, accentColor: .blue)
    @State private var selectedCycleOption = 1 // 1 for "This Cycle", 0 for "Last Cycle"

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
                    Picker(selection: $selectedCycleOption, label: Text("")) {
                        Text("Last Cycle").tag(0)
                        Text("This Cycle").tag(1)
                        
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
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
                OverviewTable(symptoms: Array(selectedSymptoms))
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
        .onReceive([selectedCycleOption].publisher.first()) { _ in
            // Logic to handle selection change (this cycle or last cycle)
            // You can update your data or perform any necessary actions here
            // For example, you might want to fetch different data based on the selectedCycleOption
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
