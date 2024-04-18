//
//  KnowledgeBaseView.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//

import SwiftUI

struct KnowledgeBaseView: View {
    // Define a state variable to store the search query
    @State private var searchQuery: String = ""
    
    // Define a state variable to track the open/closed state of each section
    @State private var isGenerellKnowledgeSectionOpen: Bool = false
    @State private var isSymptomesSectionOpen: Bool = false
    @State private var isCycleSyncSectionOpen: Bool = false
    
    var body: some View {
        VStack {
            // Title
            Text("Knowledge Base")
                            .font(.title)
                            .fontWeight(.bold)
            // Search field
            TextField("Search", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Accordion-style round boxes
            VStack(spacing: 10) {
                DisclosureGroup("Generell knowledge", isExpanded: $isGenerellKnowledgeSectionOpen) {
                    Text("How does the menstrual cycle work")
                }
                .accentColor(.white)
                .foregroundColor(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                
                DisclosureGroup("Symptomes", isExpanded: $isSymptomesSectionOpen) {
                    Text("Headache")
                    Text("Cramps")
                }
                .accentColor(.white)
                .foregroundColor(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                
                DisclosureGroup("Cycle sync", isExpanded: $isCycleSyncSectionOpen) {
                    Text("Sleep")
                    Text("Stress")
                    Text("Activity")
                }
                .accentColor(.white)
                .foregroundColor(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
            }
            .padding()
        }
    }
}

struct KnowledgeBaseView_Previews: PreviewProvider {
    static var previews: some View {
        KnowledgeBaseView()
    }
}

