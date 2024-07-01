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
    @StateObject var themeManager = ThemeManager()
        
    
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
        .accentColor(themeManager.theme.primaryColor.toColor())
        .environmentObject(themeManager)
        .overlay(
           // CyMe Icon
            VStack {
                Spacer()
                    Image("Icon")
                        .resizable()
                        .frame(width: 60, height: 60)
                .padding(.bottom, 1500)
                .padding(.leading, 20)
            }
        )
        .overlay(
            VStack {
                Spacer()
                Button(action: {
                    isSelfReportPresented = true
                    connector.sendSettings()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(themeManager.theme.accentColor.toColor())
                }
                .padding(.bottom, 40)
            }
        )
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        isSettingsPresented = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(themeManager.theme.accentColor.toColor())
                    }
                    .padding(.bottom, 700)
                    .padding(.trailing, 20)
                    .sheet(isPresented: $isSettingsPresented) {
                        SettingsView(isPresented: $isSettingsPresented)
                    }
                }
            }
            , alignment: .topTrailing
        )
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NotificationTapped"))) { _ in
            DispatchQueue.main.async {
                isSelfReportPresented = true
            }
        }
        .popup(isPresented: $isSelfReportPresented) {
            SelfReportView(settingsViewModel: settingsViewModel, isPresented: $isSelfReportPresented)
        }
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // TODO add action which shows random facts about menstrual health
                    }) {
                        
                        Image("shortIcon")
                            .resizable()
                            .frame(width: 70, height: 70)
                    }
                    .padding(.bottom, 700)
                    .padding(.trailing, 320)
                }
            }
            , alignment: .topTrailing
        )
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
