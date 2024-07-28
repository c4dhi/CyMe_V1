//
//  MultiGraphLegend.swift
//  CyMe
//
//  Created by Marinja Principe on 24.07.2024.
//

import SwiftUI

struct MultiGraphLegend: View {
    @State private var theme: ThemeModel = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: lightBlue, accentColor: .blue)
    let customColor = Color(red: 211 / 255.0, green: 231 / 255.0, blue: 255 / 255.0)

    
    var body: some View {
        HStack {
            HStack {
                Circle()
                    .fill(customColor)
                    .frame(width: 10, height: 10)
                Text("Last cycle")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            .padding(.trailing, 10)
            
            HStack {
                Circle()
                    .fill(.blue)
                    .frame(width: 10, height: 10)
                Text("Current cycle")
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
        }
        .padding(.top, 10)
    }
}

#Preview {
    MultiGraphLegend()
}
