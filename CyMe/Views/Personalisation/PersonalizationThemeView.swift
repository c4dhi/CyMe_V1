//
//  PersonalizationThemeView.swift
//  CyMe
//
//  Created by Marinja Principe on 13.05.24.
//

import SwiftUI

let lightBlue = Color(red: 0.5, green: 0.5, blue: 1.0)
let lightGreen = Color(red: 0.5, green: 1.0, blue: 0.5)
let deepGreen = Color(red: 0.0, green: 0.5, blue: 0.0)

struct PersonalizationThemeView: View {
    @State private var selectedThemeIndex = 0
    @State private var selectedColorIndex = 0
    @State private var customColor = Color.white // Initial custom color
    @State private var enableWidget = false
    @State private var enableWatchReporting = false
    @State private var isCustomColorPickerShown = false // Track if custom color picker is shown
    
    var themes = ["Girly Girl", "Deep Blue", "Plant Green", "Blood Red", "Custom"] // Added "Custom" theme
    
    @State private var  colors: [[Color]] = [
        [.pink, .purple, .white],    // Girly Girl
        [.blue, lightBlue, .white],  // Deep Blue
        [deepGreen, lightGreen, .white],    // Plant Green
        [.red, .orange, .yellow],    // Blood Red
        [.white, .white, .white]     // Custom (initially white)
    ]
    
    var nextPage: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Personalize CyMe look and feel")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            // Theme selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Select Theme:")
                Picker("Theme", selection: $selectedThemeIndex) {
                    ForEach(0..<themes.count, id: \.self) { index in
                        Text(themes[index])
                        
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(minWidth: 20)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Color boxes
            HStack(spacing: 8) {
                ForEach(0..<colors[selectedThemeIndex].count, id: \.self) { index in
                    Rectangle()
                        .fill(colors[selectedThemeIndex][index])
                        .frame(width: 50, height: 50)
                        .border(Color.black, width: 1) // Add black border
                        .cornerRadius(8)
                        .onTapGesture {
                            if selectedThemeIndex == themes.count - 1 { // If "Custom" theme is selected
                                selectedColorIndex = index
                                isCustomColorPickerShown = true // Show custom color picker
                            }
                        }
                }
            }
            .padding(.horizontal)
            
            // Enable self-reporting widget on iPhone
            Toggle("Enable self-reporting widget on iPhone", isOn: $enableWidget)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            // Enable self-reporting on Apple Watch
            Toggle("Enable self-reporting on Apple watch", isOn: $enableWatchReporting)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            Button(action: nextPage) {
                Text("Finished")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .popover(isPresented: $isCustomColorPickerShown) {
            VStack {
                ColorPicker("Custom Color", selection: $colors[selectedThemeIndex][selectedColorIndex], supportsOpacity: false)
                                    .padding()
                    .padding()
                
                Button(action: {
                    isCustomColorPickerShown = false // Dismiss color picker
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
        PersonalizationThemeView(nextPage: {})
    }
}
