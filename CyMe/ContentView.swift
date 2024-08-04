import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connector: WatchConnector
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @State private var isSettingsPresented = false
    @State private var isSelfReportPresented = false
    @State var discoverViewModel = DiscoverViewModel()
                
    @StateObject var themeManager = ThemeManager()
        
    var body: some View {
        ZStack {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                DiscoverView(viewModel: discoverViewModel, settingsViewModel : settingsViewModel)
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Discover")
                    }
                VisualisationView(viewModel: discoverViewModel, settingsViewModel : settingsViewModel)
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Visualisation")
                    }
                KnowledgeBaseView()
                    .tabItem {
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
                            withAnimation {
                                isSettingsPresented.toggle()
                            }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(themeManager.theme.accentColor.toColor())
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 700)
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
                            connector.sendSettings(settings: settingsViewModel.settings)
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
            
            if isSettingsPresented {
                GeometryReader { geometry in
                    VStack {
                        HStack {
                            Spacer()
                            SettingsNavigationView(settingsViewModel: settingsViewModel, isPresented: $isSettingsPresented)
                                .offset(x: -20, y: 50) // Adjust the offset as needed to position correctly
                        }
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topTrailing)
                    .background(Color.black.opacity(0.3).edgesIgnoringSafeArea(.all).onTapGesture {
                        isSettingsPresented = false
                    })
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
