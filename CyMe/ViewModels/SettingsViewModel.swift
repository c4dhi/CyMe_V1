//
//  File.swift
//  CyMe
//
//  Created by Marinja Principe on 22.05.24.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var settings: SettingsModel
    
    private var settingsDatabaseService: SettingsDatabaseService
        
    init() {
        settingsDatabaseService = SettingsDatabaseService()
        self.settings = settingsDatabaseService.getDefaultSettings()
    }
    
    func saveSettings() {
        settingsDatabaseService.saveSettings(settings: settings)
    }
    
}

