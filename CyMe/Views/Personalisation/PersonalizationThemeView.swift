//
//  PersonalizationThemeView.swift
//  CyMe
//
//  Created by Marinja Principe on 13.05.24.
//

import SwiftUI

enum ColorType {
    case background, primary, accent
}

struct PersonalizationThemeView: View {
    var nextPage: () -> Void
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    @State private var theme: ThemeModel = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: lightBlue, accentColor: .blue)
    @State private var selectedThemeIndex = 0
    @State private var selectedColorType: ColorType? = nil
    @State private var isCustomColorPickerShown = false

    @State private var themes: [ThemeModel] = [
        ThemeModel(name: "Deep blue", backgroundColor: .white, primaryColor: lightBlue, accentColor: .blue),  // Deep blue
        ThemeModel(name: "Girly girl", backgroundColor: .white, primaryColor: .purple, accentColor: .pink),    // Girly girl
        ThemeModel(name: "Plant green", backgroundColor: .white, primaryColor: deepGreen, accentColor: lightGreen),    // Plant green
        ThemeModel(name: "Blood red", backgroundColor: .white, primaryColor: .red, accentColor: .orange),    // Blood red
        ThemeModel(name: "Custom", backgroundColor: .white, primaryColor: .white, accentColor: .white)    // Custom (initially white)
    ]

    var body: some View {
        Text("Personalize CyMe look and feel")
       .font(.title)
       .fontWeight(.bold)
       .padding()
       .frame(maxWidth: .infinity, alignment: .leading)
       .background(settingsViewModel.settings.selectedTheme.primaryColor.toColor())
            Form {
                Section(header: Text("Personalize CyMe theme")) {
                    Text("Select your prefered theme:")
                    Picker("Theme", selection: $selectedThemeIndex) {
                        ForEach(0..<$themes.count, id: \.self) { index in
                            Text(themes[index].name)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)
                    .padding()
                    // Color boxes
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(themes[selectedThemeIndex].primaryColor.toColor())
                            .frame(width: 50, height: 50)
                            .border(Color.black, width: 1)
                            .cornerRadius(8)
                            .onTapGesture {
                                if selectedThemeIndex == themes.count - 1 { // If "Custom" theme is selected
                                    selectedColorType = .primary
                                    isCustomColorPickerShown = true
                                }
                            }
                        Rectangle()
                            .fill(themes[selectedThemeIndex].accentColor.toColor())
                            .frame(width: 50, height: 50)
                            .border(Color.black, width: 1)
                            .cornerRadius(8)
                            .onTapGesture {
                                if selectedThemeIndex == themes.count - 1 { // If "Custom" theme is selected
                                    selectedColorType = .accent
                                    isCustomColorPickerShown = true
                                }
                            }
                        Rectangle()
                            .fill(themes[selectedThemeIndex].backgroundColor.toColor())
                            .frame(width: 50, height: 50)
                            .border(Color.black, width: 1)
                            .cornerRadius(8)
                            .onTapGesture {
                                if selectedThemeIndex == themes.count - 1 { // If "Custom" theme is selected
                                    selectedColorType = .background
                                    isCustomColorPickerShown = true
                                }
                            }
                    }
                    .padding(.horizontal)
                }

                Section(header: Text("Extend user experience")) {
                    Toggle("Enable self-reporting widget on iPhone", isOn: $settingsViewModel.settings.enableWidget)
                        .padding(.horizontal)
                }
            }
            .onChange(of: selectedThemeIndex) { newValue in
                settingsViewModel.settings.selectedTheme = themes[newValue]
            }
            .onAppear {
                if let savedTheme = UserDefaults.standard.themeModel(forKey: "theme") {
                    settingsViewModel.settings.selectedTheme = savedTheme
                    if let index = themes.firstIndex(where: { $0.name == savedTheme.name }) {
                        selectedThemeIndex = index
                    } else {
                        themes[themes.count - 1] = savedTheme // Set the custom theme
                        selectedThemeIndex = themes.count - 1
                    }
                }
            }

            Button(action: {
                // TODO add validation
                settingsViewModel.saveSettings()
                nextPage()
            }) {
                Text("Finished")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(settingsViewModel.settings.selectedTheme.accentColor.toColor())
                    .cornerRadius(10)
            }
            .popover(isPresented: $isCustomColorPickerShown) {
                VStack {
                    ColorPicker("Select your custom color", selection: Binding<Color>(
                        get: {
                            switch selectedColorType {
                            case .background: return themes[selectedThemeIndex].backgroundColor.toColor()
                            case .primary: return themes[selectedThemeIndex].primaryColor.toColor()
                            case .accent: return themes[selectedThemeIndex].accentColor.toColor()
                            case .none: return .white
                            }
                        },
                        set: { newValue in
                            switch selectedColorType {
                            case .background: themes[selectedThemeIndex].backgroundColor = CodableColor(color: newValue)
                            case .primary: themes[selectedThemeIndex].primaryColor = CodableColor(color: newValue)
                            case .accent: themes[selectedThemeIndex].accentColor = CodableColor(color: newValue)
                            case .none: break
                            }
                        }
                    ))
                    .padding()

                    Button(action: {
                        isCustomColorPickerShown = false
                    }) {
                        Text("Done")
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
        }
    }
}


struct PersonalizationThemeView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalizationThemeView(nextPage: {}, settingsViewModel: SettingsViewModel(connector: WatchConnector()))
    }
}
