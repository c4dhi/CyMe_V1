//
//  MultiGraphLegend.swift
//  CyMe
//
//  Created by Marinja Principe on 24.07.2024.
//

import SwiftUI

struct MultiGraphLegend: View {
    let customColor = Color(red: 211 / 255.0, green: 231 / 255.0, blue: 255 / 255.0)
    var availableCycles : Int
    
    var body: some View {
        
        let label1 = availableCycles > 2 ? "Last cycle" : "Current cycle"
        let label2 = availableCycles > 2 ? "Second to last cycle" : "Last cycle"
        
        HStack {
            HStack {
                Circle()
                    .fill(customColor)
                    .frame(width: 10, height: 10)
                Text(label1)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            .padding(.trailing, 10)
            
            HStack {
                Circle()
                    .fill(.blue)
                    .frame(width: 10, height: 10)
                Text(label2)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
        }
        .padding(.top, 10)
    }
}

#Preview {
    MultiGraphLegend(availableCycles: 2)
}
