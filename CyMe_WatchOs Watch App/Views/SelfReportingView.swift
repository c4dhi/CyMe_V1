//
//  SelfReportingView.swift
//  CyMe_WatchOs Watch App
//
//  Created by Marinja Principe on 08.05.24.
//

//
//  SettingsView.swift
//  CyMe
//
//  Created by Marinja Principe on 08.05.24.
//

import SwiftUI

struct SelfReportingView: View {
    @State private var hasPeriod: Bool = false
    @State private var hasHeadache: Bool = false
    @State private var isLoading: Bool = false
    
    @ObservedObject var userReporting: UserReportingOptions
    @StateObject var connector: iOSConnector

    init(userReporting: UserReportingOptions) {
        self.userReporting = userReporting
        _connector = StateObject(wrappedValue: iOSConnector(userReporting: .constant(userReporting)))
    }
    var body: some View {
        ZStack{
            NavigationView {
                ScrollView {
                    VStack {
                        if userReporting.periodTrackingEnabled {
                            Text("Did you have your period?")
                            
                            HStack {
                                Button(action: {
                                    self.hasPeriod = true
                                }) {
                                    Text("Yes")
                                        .padding()
                                        .background(hasPeriod ? Color.blue : Color.clear) // Highlight selected button
                                        .foregroundColor(hasPeriod ? .white : .blue) // Change text color for selected button
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    self.hasPeriod = false
                                }) {
                                    Text("No")
                                        .padding()
                                        .background(!hasPeriod ? Color.red : Color.clear) // Highlight selected button
                                        .foregroundColor(!hasPeriod ? .white : .red) // Change text color for selected button
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        if userReporting.headacheTrackingEnabled {
                            
                            Text("Did you experience headache today?")
                            
                            HStack {
                                Button(action: {
                                    self.hasHeadache = true
                                }) {
                                    Text("Yes")
                                        .padding()
                                        .background(hasHeadache ? Color.blue : Color.clear) // Highlight selected button
                                        .foregroundColor(hasHeadache ? .white : .blue) // Change text color for selected button
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    self.hasHeadache = false
                                }) {
                                    Text("No")
                                        .padding()
                                        .background(!hasHeadache ? Color.red : Color.clear) // Highlight selected button
                                        .foregroundColor(!hasHeadache ? .white : .red) // Change text color for selected button
                                        .cornerRadius(8)
                                }
                            }
                        }
                        Button {
                            submitSelfReport()
                            
                        } label: {
                            Text("Submit")
                        }
                    }
                    .padding()
                }
                .navigationTitle("CyMe Self-Reporting")
            }
            
            if isLoading {
                Color.primary.opacity(0.7)
                ProgressView()
            }
        }
        .ignoresSafeArea()
    }
    
    func submitSelfReport() {
        Task{
            do {
                print(userReporting.periodTrackingEnabled)
                print(userReporting.headacheTrackingEnabled)
                isLoading = true // Show loading indicator
                print("button clicked")
                // Prepare self-report data
                let selfReport = SelfReportModel(hasPeriod: hasPeriod, hasHeadache: hasHeadache)
                print(selfReport)
                
                // Send self-report data to iOS app
                connector.sendSelfReportDataToiOS(selfReport: selfReport)
                
                // After sending data, stop loading indicator
                isLoading = false
                
            } catch {
                isLoading = false
                print(error.localizedDescription)
            }
        }
    }

}

struct SelfReportingView_Previews: PreviewProvider {
    static var previews: some View {
        let userReporting = UserReportingOptions()
        userReporting.periodTrackingEnabled = true // Set the period tracking enabled to true for preview
        
        return SelfReportingView(userReporting: userReporting)
    }
}


