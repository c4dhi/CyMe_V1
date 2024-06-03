//
//  PopUpView.swift
//  CyMe
//
//  Created by Marinja Principe on 02.06.24.
//

import SwiftUI


struct PopupView<Content: View>: View {
    @Binding var isPresented: Bool
    @State private var showConfirmation = false
    let content: Content

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }

    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isPresented = false
                    }

                VStack {
                    content
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.5)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 20)
                        .overlay(
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        showConfirmation = true
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(.gray)
                                    }
                                    .alert(isPresented: $showConfirmation) {
                                        Alert(
                                            title: Text("Are you sure you want to close this?"),
                                            primaryButton: .default(Text("Cancel")),
                                            secondaryButton: .destructive(Text("Close"), action: {
                                                isPresented = false
                                            })
                                        )
                                    }
                                }
                                .padding()
                                Spacer()
                            }
                        )
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: isPresented)
            }
        }
    }
}

extension View {
    func popup<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(PopupModifier(isPresented: isPresented, content: content))
    }
}

struct PopupModifier<PopupContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let content: () -> PopupContent

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                PopupView(isPresented: $isPresented) {
                    self.content()
                }
            }
        }
    }
}

