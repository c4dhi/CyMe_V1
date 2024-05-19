//
//  SelfReportinView.swift
//  CyMe
//
//  Created by Marinja Principe on 15.05.24.
//

import SwiftUI

struct SelfReportView: View {
    @State private var hasPeriod: Bool = false
    @State private var hasHeadache: Bool = false
    @State private var isLoading: Bool = false
    @Binding var isPresented: Bool
    
    var periodTrackingEnabled = true
    var headacheTrackingEnabled = true
    
    var body: some View {
        ZStack{
            NavigationView {
                ScrollView {
                    VStack {
                        if periodTrackingEnabled {
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
                        
                        if headacheTrackingEnabled {
                            
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
                .navigationBarItems(trailing: Button("close") {
                    // Dismiss settings view
                    isPresented = false
                })
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
                
            } catch {
                isLoading = false
                print(error.localizedDescription)
            }
        }
    }

}

struct SelfReportView_Previews: PreviewProvider {
    static var previews: some View {
        
        return SelfReportView(isPresented: .constant(true))
    }
}

