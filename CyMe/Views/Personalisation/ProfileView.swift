//
//  ProfileView.swift
//  CyMe
//
//  Created by Marinja Principe on 09.05.24.
//

import SwiftUI

import SwiftUI

struct ProfileView: View {
    @State private var name = ""
    @State private var age = ""
    @State private var lifePhase = ""
    @State private var isRegularCycle = false
    @State private var fertilityGoal = ""
    @State private var contraceptionOptions: [String] = []
    @State private var cycleLength = ""

    let lifePhaseOptions = ["Premenopause", "Menopause", "Postmenopause"]
    let fertilityGoalOptions = ["Pregnancy", "Avoiding Pregnancy", "Exploring Options"]

    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("Name", text: $name)
                TextField("Age", text: $age)
                Picker("Life Phase", selection: $lifePhase) {
                    ForEach(lifePhaseOptions, id: \.self) {
                        Text($0)
                    }
                }
            }

            Section(header: Text("Menstrual Health")) {
                Toggle("Regular Menstrual Cycle", isOn: $isRegularCycle)
                if isRegularCycle {
                    TextField("Cycle Length", text: $cycleLength)
                }
            }

            Section(header: Text("Fertility and Contraception")) {
                Picker("Fertility Goal", selection: $fertilityGoal) {
                    ForEach(fertilityGoalOptions, id: \.self) {
                        Text($0)
                    }
                }

                MultipleSelectionPicker(
                    title: "Contraception",
                    options: ["Pill", "Condom", "IUD", "Sterilization"],
                    selectedOptions: $contraceptionOptions
                )
            }

            Section {
                Button(action: {
                    // Action to start the journey
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("Primary"))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Profile")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

struct MultipleSelectionPicker: View {
    var title: String
    var options: [String]
    @Binding var selectedOptions: [String]

    @State private var isPickerPresented = false

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(selectedOptions.joined(separator: ", "))
                .foregroundColor(.gray)
        }
        .onTapGesture {
            isPickerPresented = true
        }
        .sheet(isPresented: $isPickerPresented) {
            MultipleSelectionPickerSheet(
                title: title,
                options: options,
                selectedOptions: $selectedOptions,
                isPickerPresented: $isPickerPresented
            )
        }
    }
}

struct MultipleSelectionPickerSheet: View {
    var title: String
    var options: [String]
    @Binding var selectedOptions: [String]
    @Binding var isPickerPresented: Bool

    var body: some View {
        NavigationView {
            List {
                ForEach(options, id: \.self) { option in
                    MultipleSelectionRow(
                        option: option,
                        isSelected: selectedOptions.contains(option)
                    ) {
                        if let index = selectedOptions.firstIndex(of: option) {
                            selectedOptions.remove(at: index)
                        } else {
                            selectedOptions.append(option)
                        }
                    }
                }
            }
            .navigationBarTitle(Text(title), displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    isPickerPresented = false
                }
            )
        }
    }
}

struct MultipleSelectionRow: View {
    var option: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        HStack {
            Text(option)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }

    }
}

