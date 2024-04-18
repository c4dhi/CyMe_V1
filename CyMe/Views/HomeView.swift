//
//  HomeView.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//

import SwiftUI

struct HomeView: View {
    // Sample data for demonstration
    let headacheCount = 5
    let moodSwingsCount = 3
    let bellyacheCount = 5
    let currentMestrualStage = "Follicular Phase"
    
    // Define the number of days in a cycle
    let numberOfDaysInCycle = 7
    
    // Calculate the angle for the small circle based on the current day
    var rotationAngle: Double {
        let currentDay = Calendar.current.component(.day, from: Date())
        let angle = Double(currentDay) / Double(numberOfDaysInCycle) * 360.0
        return -angle // Negative angle for clockwise rotation
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Cycle visualization
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 15)
                    .frame(width: 200, height: 200)
                ForEach(0..<numberOfDaysInCycle) { day in
                    Circle()
                        .fill(day == currentDay() - 1 ? Color.blue : Color.gray)
                        .frame(width: 10, height: 10)
                        .rotationEffect(.degrees(Double(day) / Double(numberOfDaysInCycle) * 360))
                        .offset(x: 90, y: 0)
                }
                Circle()
                    .fill(Color.blue)
                    .frame(width: 15, height: 15)
                    .rotationEffect(.degrees(rotationAngle))
                    .offset(x: 90, y: 0)
                Text("Day \(currentDay())")
                                    .foregroundColor(.black)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .offset(x: 0, y: 0)
                Text(currentMestrualStage)
                                    .foregroundColor(.black)
                                    .font(.headline)
                                    .offset(x: 0, y: 130)
            }
            .offset(y: 80)
            
            // FactSquare components
            HStack(spacing: 10) {
                Spacer()
                FactSquare(title: "Headache counts", count: headacheCount)
                Spacer()
                FactSquare(title: "Mood swings", count: moodSwingsCount)
                Spacer()
                FactSquare(title: "Bellyache", count: bellyacheCount)
                Spacer()
            }
            .padding()
            .offset(y:-80)
        }
    }
    
    // Function to get the current day of the month
    private func currentDay() -> Int {
        return Calendar.current.component(.day, from: Date())
    }
}


struct FactSquare: View {
    let title: String
    let count: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue)
                .frame(width: 80, height: 80)
            VStack {
                Text("\(count)")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.top, 10.0)
                Spacer()
            }
            Text(title)
                .foregroundColor(.white)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.top, 30.0)
                .frame(width: 70.0, height: 70.0)
        }
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

