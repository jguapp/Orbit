import SwiftUI

class SettingsViewModel: ObservableObject {
    @AppStorage("pomodoroLength") var workMinutes: Int = 25
    @AppStorage("breakLength") var breakMinutes: Int = 5
    @AppStorage("notifications") var notificationsEnabled: Bool = true
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("hapticFeedback") var hapticFeedbackEnabled: Bool = true
    @AppStorage("theme") var selectedTheme: Theme = .cosmic
    
    enum Theme: String, CaseIterable {
        case cosmic = "Cosmic"
        case ocean = "Ocean"
        case forest = "Forest"
        case sunset = "Sunset"
        
        var colors: [Color] {
            switch self {
            case .cosmic:
                return [Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.2, green: 0.1, blue: 0.3),
                        Color(red: 0.1, green: 0.0, blue: 0.2)]
            case .ocean:
                return [.blue, .teal, .cyan]
            case .forest:
                return [.green, .mint, .teal]
            case .sunset:
                return [.orange, .pink, .purple]
            }
        }
    }
}