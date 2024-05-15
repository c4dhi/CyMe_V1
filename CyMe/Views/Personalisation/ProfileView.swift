//
//  ProfileView.swift
//  CyMe
//
//  Created by Marinja Principe on 09.05.24.
//

import SwiftUI

struct ProfileView: View {
    var nextPage: () -> Void
    @State private var name = ""
    @State private var age = ""
    @State private var lifePhase = "Premenopause"
    @State private var isRegularCycle = false
    @State private var fertilityGoal = "Avoiding pregnancy"
    @State private var contraceptionOptions: [String] = []
    @State private var cycleLength = ""

    let lifePhaseOptions = ["Premenopause", "Menopause", "Postmenopause"]
    let fertilityGoalOptions = ["Avoiding pregnancy", "Pregnancy",  "Exploring options"]

    var body: some View {
        Form {
            Section(header: Text("Personal information")) {
                TextField("Name", text: $name)
                TextField("Age", text: $age)
            }
            
            Section(header: Text("Menstrual health")) {
                Picker("Life Phase", selection: $lifePhase) {
                    ForEach(lifePhaseOptions, id: \.self) {
                        Text($0)
                    }
                }
                Toggle("Regular menstrual cycle", isOn: $isRegularCycle)
                if isRegularCycle {
                    TextField("Cycle Length", text: $cycleLength)
                }
            }
            
            Section(header: Text("Fertility and contraception")) {
                Picker("Fertility goal", selection: $fertilityGoal) {
                    ForEach(fertilityGoalOptions, id: \.self) {
                        Text($0)
                    }
                }
                if fertilityGoal != "Pregnancy" {
                    MultipleSelectionPicker(
                        title: "Contraception",
                        options: ["None", "Pill", "Condom", "IUD", "Sterilization"],
                        selectedOptions: $contraceptionOptions
                    )
                }

            }
            
            Button(action: {
                if isInputValid() {
                    nextPage()
                } else {
                    // Show an alert or message indicating that all fields are required
                    // You can also highlight the fields that are missing
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isInputValid() ? Color.blue : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(!isInputValid())

            
        }
        .navigationTitle("Profile")
    }
    
    func isInputValid() -> Bool {
        // Check if all required fields are filled
        return !name.isEmpty && !lifePhase.isEmpty && !fertilityGoal.isEmpty && ( fertilityGoal == "Pregnancy" || !$contraceptionOptions.isEmpty )
    }

}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(nextPage: {})
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

