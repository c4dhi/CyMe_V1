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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
