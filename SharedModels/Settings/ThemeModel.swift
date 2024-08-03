import Foundation
import SwiftUI


let lightBlue = Color(red: 0.2, green: 0.7, blue: 1.0)

let lightGreen = Color(red: 151/255, green: 188/255, blue: 98/255)
let deepGreen = Color(red: 44/255, green: 95/255, blue: 45/255)

let lightPink = Color(red: 223/255, green: 101/255, blue: 137/255)
let deepViolett = Color(red: 60/255, green: 16/255, blue: 83/255)

let lightOrange = Color(red: 221/255, green: 65/255, blue: 50/255)
let bloodRed = Color(red: 158/255, green: 16/255, blue: 48/255)

let candyPink = Color(red: 215/255, green: 169/255, blue: 227/255) // #D7A9E3FF
let candyBlue = Color(red: 139/255, green: 190/255, blue: 232/255) // #8BBEE8FF
let candyGreen = Color(red: 224/255, green: 252/255, blue: 230/255)

struct ThemeModel: Codable {
    var name: String
    var backgroundColor: CodableColor
    var primaryColor: CodableColor
    var accentColor: CodableColor

    init(name: String, backgroundColor: Color, primaryColor: Color, accentColor: Color) {
        self.name = name
        self.backgroundColor = CodableColor(color: backgroundColor)
        self.primaryColor = CodableColor(color: primaryColor)
        self.accentColor = CodableColor(color: accentColor)
    }
}


struct CodableColor: Codable {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat

    init(color: Color) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    func toColor() -> Color {
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }
}

extension UserDefaults {
    func setThemeModel(_ theme: ThemeModel?, forKey key: String) {
        guard let theme = theme else {
            removeObject(forKey: key)
            return
        }
        if let data = try? JSONEncoder().encode(theme) {
            set(data, forKey: key)
        }
    }

    func themeModel(forKey key: String) -> ThemeModel? {
        guard let data = data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(ThemeModel.self, from: data)
    }
}

class ThemeManager: ObservableObject {
    @Published var theme: ThemeModel
    
    init() {
        self.theme = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: lightBlue, accentColor: .blue)
    }
    
    func saveThemeToUserDefaults(newTheme: ThemeModel) {
        UserDefaults.standard.setThemeModel(newTheme, forKey: "theme")
        self.theme = UserDefaults.standard.themeModel(forKey: "theme") ?? newTheme
    }
    
    func loadTheme() {
        self.theme = UserDefaults.standard.themeModel(forKey: "theme") ?? ThemeModel(name: "Default", backgroundColor: .white, primaryColor: lightBlue, accentColor: .blue)
        }
}

