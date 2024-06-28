//
//  ContentView.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var connector = WatchConnector()
    @State private var isSettingsPresented = false
    @State private var isSelfReportPresented = false
    @StateObject var settingsViewModel = SettingsViewModel()
    @State var discoverViewModel = DiscoverViewModel()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem() {
                    Image(systemName: "house")
                    Text("Home")
                }
            DiscoverView(viewModel: discoverViewModel)
                .tabItem() {
                    Image(systemName: "magnifyingglass")
                    Text("Discover")
                }
            VisualisationView(viewModel: discoverViewModel)
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
                    isSelfReportPresented = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 40)
            }
        )
        .overlay(
            // Settings Button overlay
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // Action for the settings button
                        isSettingsPresented = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom, 1500) // TODO make better
                    .padding(.trailing, 20)
                    .sheet(isPresented: $isSettingsPresented) {
                        // Present settings view here
                        SettingsView(isPresented: $isSettingsPresented)
                    }
                }
            }
            , alignment: .topTrailing
        )
        .popup(isPresented: $isSelfReportPresented) {
                    SelfReportView(settingsViewModel: settingsViewModel, isPresented: $isSelfReportPresented)
                }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
