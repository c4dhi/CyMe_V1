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
    
    private var themeManager = ThemeManager()
    
    private var settingsDatabaseService: SettingsDatabaseService
        
    init() {
        settingsDatabaseService = SettingsDatabaseService()
        self.settings = settingsDatabaseService.getSettings() ?? settingsDatabaseService.getDefaultSettings()
    }
    
    func saveSettings() {
        themeManager.saveThemeToUserDefaults(newTheme: settings.selectedTheme)
        settingsDatabaseService.saveSettings(settings: settings)
    }
}


