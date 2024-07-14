//
//  WelcomeView.swift
//  CyMe
//
//  Created by Marinja Principe on 09.05.24.
//

import SwiftUI

struct WelcomeView: View {
    var nextPage: () -> Void
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image("Icon")
                .resizable()
                .frame(width: 280, height: 280)
            Text("Welcome to CyMe")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("Are you ready to start this journey with us?")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            
            Button(action: nextPage) {
                Text("Start my journey")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(settingsViewModel.settings.selectedTheme.accentColor.toColor())
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Welcome")
    }
}


struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(nextPage: {}, settingsViewModel: SettingsViewModel())
    }
}
