import SwiftUI

struct VisualisationView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State private var selectedSymptoms: Set<SymptomModel> = []
    @State private var showingFilterSheet = false
    @EnvironmentObject var themeManager: ThemeManager
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
                            .foregroundColor(themeManager.theme.primaryColor.toColor())
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
            Logger.shared.log("Visualisation view is shown")
            themeManager.loadTheme()
            Task{
                await viewModel.updateSymptoms(currentCycle: (selectedCycleOption == 1), settingsViewModel: settingsViewModel)
                selectedSymptoms = Set(viewModel.symptoms)
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            SymptomFilterView(symptoms: viewModel.symptoms, selectedSymptoms: $selectedSymptoms, showingFilterSheet: $showingFilterSheet)
        }
        .onChange(of: selectedCycleOption){ newValue in
            let rememberSelectedSymptoms = selectedSymptoms
            Task{
                await viewModel.updateChoice(currentCycle: (selectedCycleOption == 1))
                selectedSymptoms = Set(rememberSelectedSymptoms)
                }
            }
            
        }
        .background(themeManager.theme.backgroundColor.toColor())
    }
}

struct VisualisationView_Previews: PreviewProvider {
    static var previews: some View {
        VisualisationView(viewModel: DiscoverViewModel(), settingsViewModel: SettingsViewModel(connector: WatchConnector()))
    }
}
