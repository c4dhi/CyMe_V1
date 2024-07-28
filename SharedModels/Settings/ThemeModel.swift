import Foundation
import SwiftUI


let lightBlue = Color(red: 0.2, green: 0.7, blue: 1.0)
let lightGreen = Color(red: 0.5, green: 1.0, blue: 0.5)
let deepGreen = Color(red: 0.0, green: 0.5, blue: 0.0)

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
        self.theme = newTheme
    }
}

