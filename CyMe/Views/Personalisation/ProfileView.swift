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

    @State private var theme: ThemeModel = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: lightBlue, accentColor: .blue)
    let lifePhaseOptions = ["Premenopause", "Menopause", "Postmenopause"]
    let fertilityGoalOptions = ["Avoiding pregnancy", "Pregnancy", "Exploring options"]

    var body: some View {
            Text("Profile")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(theme.primaryColor.toColor())
            
            Form {
                Section(header: Text("Personal information")) {
                    TextField("Name", text: $userViewModel.user.name)
                    TextField("User ID", text: $userViewModel.user.userId)
                    TextField("Age", text: Binding(
                        get: {
                                if let age = userViewModel.user.age {
                                    return String(age)
                                } else {
                                    return ""
                                }
                            },
                            set: {
                                if let value = Int($0) {
                                    userViewModel.user.age = value
                                } else {
                                    userViewModel.user.age = nil
                                }
                            }
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
                            get: {
                                if let cycleLength = userViewModel.user.cycleLength {
                                    return String(cycleLength)
                                } else {
                                    return ""
                                }
                            },
                            set: {
                                if let value = Int($0) {
                                    userViewModel.user.cycleLength = value
                                } else {
                                    userViewModel.user.cycleLength = nil
                                }
                            }
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
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isInputValid() ? theme.accentColor.toColor() : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(!isInputValid())
            .padding()
    }

    func isInputValid() -> Bool {
        return !userViewModel.user.name.isEmpty && (userViewModel.user.age != nil && userViewModel.user.age! >= 18) && !userViewModel.user.lifePhase.isEmpty && !userViewModel.user.fertilityGoal.isEmpty && (userViewModel.user.fertilityGoal == "Pregnancy" || !userViewModel.user.contraceptions.isEmpty)
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let connector = WatchConnector()
        ProfileView(nextPage: {}, settingsViewModel: SettingsViewModel(connector: connector), userViewModel: ProfileViewModel())
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
