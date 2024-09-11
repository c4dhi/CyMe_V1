//
//  HomeView.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//
// Responsible for the display of the home page 
import SwiftUI

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @EnvironmentObject var themeManager: ThemeManager

    let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter
        }()
    
    var circlePosition: (x: CGFloat, y: CGFloat) {
        let angle = Double(homeViewModel.cycleDay - 1) / Double(homeViewModel.cycleLength - 1) * 2 * .pi - .pi / 2
        let xPosition = homeViewModel.circleRadius * CGFloat(cos(angle))
        let yPosition = homeViewModel.circleRadius * CGFloat(sin(angle))
        return (x: xPosition, y: yPosition)
    }
    
    @State private var selectedTabIndex = 0
    
    var body: some View {
        VStack(spacing: 10) {
            // Cycle visualization
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 15)
                    .frame(width: 200, height: 200)
                Circle()
                    .fill(themeManager.theme.primaryColor.toColor())
                    .frame(width: 20, height: 20)
                    .offset(x: circlePosition.x, y: circlePosition.y)
                Text("Day \(homeViewModel.cycleDay)")
                    .foregroundColor(.black)
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Welcome to CyMe, \(homeViewModel.userName)!")
                    .foregroundColor(.black)
                    .font(.headline)
                    .offset(x: 0, y: 130)
                Text("Enjoy exploring your personalized tracker!")
                    .foregroundColor(.black)
                    .offset(x: 0, y: 190)
            }
            .padding(.top, 20)
            
            // Daily summary box
            VStack(spacing: 10) {
                Text("Daily summary")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.top, 10)
                Text("Total reports today: \(homeViewModel.reports.count)")
                    .foregroundColor(.black)
            }
            .padding()
            .background(themeManager.theme.primaryColor.toColor().opacity(0.2))
            .cornerRadius(10)
            .padding(.top, 150)
            
            // Reported notes
            VStack(spacing: 0) {
                Text("Reported notes")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // TabView for swiping through report cards
                TabView(selection: $selectedTabIndex) {
                    ForEach(homeViewModel.reports.indices, id: \.self) { index in
                        ReportCard(report: homeViewModel.reports[index].notes ?? "-", date: dateFormatter.string(from: homeViewModel.reports[index].endTime))
                            .frame(width: 300) // Adjust the width of each card as needed
                            .tag(index)
                            .padding(.top, -40)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .padding(.horizontal)
                .onAppear {
                    Logger.shared.log("Home view is shown")
                    homeViewModel.fetchReports()
                    themeManager.loadTheme()
                }
               
            }
            .padding(.bottom, 40)
        }
        .background(themeManager.theme.backgroundColor.toColor())
    }
}

struct ReportCard: View {
    let report: String
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(date)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(report)
                .font(.body)
                .foregroundColor(.black)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
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
