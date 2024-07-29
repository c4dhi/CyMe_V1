import SwiftUI

struct KnowledgeBaseView: View {
    // Define a state variable to store the search query
    @State private var searchQuery: String = ""
    
    // Define a state variable to track the open/closed state of each section
    @State private var isGeneralKnowledgeSectionOpen: Bool = false
    @State private var isSymptomsSectionOpen: Bool = false
    @State private var isCycleSyncSectionOpen: Bool = false
    @State private var theme: ThemeModel = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: lightBlue, accentColor: .blue)
    
    // Sample data for the knowledge base
    let generalKnowledge = [
        "How does the menstrual cycle work": "The menstrual cycle is a series of natural changes in hormone production and the structures of the uterus and ovaries that make pregnancy possible.",
        "Phases of the menstrual cycle": "The menstrual cycle is divided into four phases: menstruation, the follicular phase, ovulation, and the luteal phase."
    ]
    
    let symptoms = [
        "Headache": "Menstrual migraines are headaches that occur before or during a woman’s period and are caused by changes in hormone levels.",
        "Cramps": "Menstrual cramps are throbbing or cramping pains in the lower abdomen experienced by many women just before and during their menstrual periods."
    ]
    
    let cycleSync = [
        "Sleep": "Sleep patterns can be affected by hormonal changes during the menstrual cycle.",
        "Stress": "Hormonal fluctuations can influence stress levels and emotional well-being.",
        "Activity": "Physical activity can help alleviate some symptoms of menstruation such as cramps and mood swings."
    ]
    
    @State private var filteredGeneralKnowledge: [String: String] = [:]
        @State private var filteredSymptoms: [String: String] = [:]
        @State private var filteredCycleSync: [String: String] = [:]
    
    var body: some View {
        ScrollView{
            VStack {
                // Title
                Text("Knowledge Base")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Search field
                TextField("Search", text: $searchQuery, onEditingChanged: { _ in
                    searchContent()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                // Accordion-style round boxes
                VStack(spacing: 10) {
                    DisclosureGroup("General Knowledge", isExpanded: $isGeneralKnowledgeSectionOpen) {
                        ForEach(generalKnowledge.keys.filter { self.searchQuery.isEmpty ? true : $0.localizedCaseInsensitiveContains(self.searchQuery) }, id: \.self) { key in
                            VStack(alignment: .leading) {
                                Text(key).font(.headline)
                                Text(generalKnowledge[key]!)
                            }
                        }
                    }
                    .accentColor(.white)
                    .foregroundColor(.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(theme.primaryColor.toColor()))
                    
                    DisclosureGroup("Symptoms", isExpanded: $isSymptomsSectionOpen) {
                        ForEach(symptoms.keys.filter { self.searchQuery.isEmpty ? true : $0.localizedCaseInsensitiveContains(self.searchQuery) }, id: \.self) { key in
                            VStack(alignment: .leading) {
                                Text(key).font(.headline)
                                Text(symptoms[key]!)
                            }
                        }
                    }
                    .accentColor(.white)
                    .foregroundColor(.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(theme.primaryColor.toColor()))
                    
                    DisclosureGroup("Cycle Sync", isExpanded: $isCycleSyncSectionOpen) {
                        ForEach(cycleSync.keys.filter { self.searchQuery.isEmpty ? true : $0.localizedCaseInsensitiveContains(self.searchQuery) }, id: \.self) { key in
                            VStack(alignment: .leading) {
                                Text(key).font(.headline)
                                Text(cycleSync[key]!)
                            }
                        }
                    }
                    .accentColor(.white)
                    .foregroundColor(.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(theme.primaryColor.toColor()))
                }
                .padding()
            }
        }
    }
    
    func searchContent() {
            if searchQuery.isEmpty {
                filteredGeneralKnowledge = generalKnowledge
                filteredSymptoms = symptoms
                filteredCycleSync = cycleSync
            } else {
                filteredGeneralKnowledge = generalKnowledge.filter { $0.key.localizedCaseInsensitiveContains(searchQuery) || $0.value.localizedCaseInsensitiveContains(searchQuery) }
                filteredSymptoms = symptoms.filter { $0.key.localizedCaseInsensitiveContains(searchQuery) || $0.value.localizedCaseInsensitiveContains(searchQuery) }
                filteredCycleSync = cycleSync.filter { $0.key.localizedCaseInsensitiveContains(searchQuery) || $0.value.localizedCaseInsensitiveContains(searchQuery) }
            }
        }
}

struct KnowledgeBaseView_Previews: PreviewProvider {
    static var previews: some View {
        KnowledgeBaseView()
    }
}
