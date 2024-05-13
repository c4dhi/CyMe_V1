//
//  WelcomeView.swift
//  CyMe
//
//  Created by Marinja Principe on 09.05.24.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text("Welcome to CyMe")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Primary"))
                
                Text("Are you ready to start this journey with us?")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("Text"))
                
                Button(action: {
                    // Action to start the journey
                }) {
                    Text("Start My Journey")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("Primary"))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
