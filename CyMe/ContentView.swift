//
//  ContentView.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem() {
                    Image(systemName: "house")
                    Text("Home")
                }
            DiscoverView(viewModel: DiscoverViewModel())
                .tabItem() {
                    Image(systemName: "magnifyingglass")
                    Text("Discover")
                }
            VisualisationView()
                .tabItem() {
                    Image(systemName: "chart.bar")
                    Text("Visualisation")
                }
            KnowledgeBaseView()
                .tabItem() {
                    Image(systemName: "book")
                    Text("Knowledge base")
                }
        }
        .overlay(
            // Plus Button overlay
            VStack {
                Spacer()
                Button(action: {
                    // Action for the plus button
                    // Add your button action here
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 40) // Adjust bottom padding as needed
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
