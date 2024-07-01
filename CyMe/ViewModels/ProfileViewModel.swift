//
//  ProfileViewModel.swift
//  CyMe
//
//  Created by Marinja Principe on 23.05.24.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: UserModel

    init() {
        self.user = UserModel(name: "", age: nil, lifePhase: "", regularCycle: false, cycleLength: nil, contraceptions: [], fertilityGoal: "")
        loadUser()
    }

    func loadUser() {
        user = DatabaseService.shared.userDatabaseService.loadUser()
    }

    func saveUser() {
        UserDefaults.standard.set(user.name, forKey: "name")
        DatabaseService.shared.userDatabaseService.saveUser(user: user)
    }
}

