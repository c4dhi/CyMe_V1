//
//  ProfileView.swift
//  CyMe
//
//  Created by Marinja Principe on 09.05.24.
//

import SwiftUI

struct ProfileView: View {
    var nextPage: () -> Void
    @ObservedObject var settingsViewModel: SettingsViewModel
    @ObservedObject var userViewModel: ProfileViewModel

    let lifePhaseOptions = ["Premenopause", "Menopause", "Postmenopause"]
    let fertilityGoalOptions = ["Avoiding pregnancy", "Pregnancy", "Exploring options"]

    var body: some View {
            Text("Profile")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(settingsViewModel.settings.selectedTheme.primaryColor)
            
            Form {
                Section(header: Text("Personal information")) {
                    TextField("Name", text: $userViewModel.user.name)
                    TextField("Age", text: Binding(
                        get: { String(userViewModel.user.age) },
                        set: { userViewModel.user.age = Int($0) ?? 0 }
                    ))
                }
                
                
                Section(header: Text("Menstrual health")) {
                    Picker("Life Phase", selection: $userViewModel.user.lifePhase) {
                        ForEach(lifePhaseOptions, id: \.self) { phase in
                            Text(phase)
                        }
                    }
                    Toggle("Regular menstrual cycle", isOn: $userViewModel.user.regularCycle)
                    if userViewModel.user.regularCycle {
                        TextField("Cycle Length", text: Binding(
                            get: { String(userViewModel.user.cycleLength) },
                            set: { userViewModel.user.cycleLength = Int($0) ?? 0 }
                        ))
                    }
                }
                Section(header: Text("Fertility and contraception")) {
                    Picker("Fertility goal", selection: $userViewModel.user.fertilityGoal) {
                        ForEach(fertilityGoalOptions, id: \.self) { goal in
                            Text(goal)
                        }
                    }
                    if userViewModel.user.fertilityGoal != "Pregnancy" {
                        MultipleSelectionPicker(
                            title: "Contraception",
                            options: ["None", "Pill", "Condom", "IUD", "Sterilization"],
                            selectedOptions: $userViewModel.user.contraceptions
                        )
                    }
                }
            }
            
            Button(action: {
                if isInputValid() {
                    userViewModel.saveUser()
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
                    .background(isInputValid() ? settingsViewModel.settings.selectedTheme.accentColor : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(!isInputValid())
            .padding()
    }

    func isInputValid() -> Bool {
        return !userViewModel.user.name.isEmpty && userViewModel.user.age > 0 && !userViewModel.user.lifePhase.isEmpty && !userViewModel.user.fertilityGoal.isEmpty && (userViewModel.user.fertilityGoal == "Pregnancy" || !userViewModel.user.contraceptions.isEmpty)
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(nextPage: {}, settingsViewModel: SettingsViewModel(), userViewModel: ProfileViewModel())
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
