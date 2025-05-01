import Foundation

struct Habit: Identifiable, Codable {
    let id: UUID
    var title: String
    var completedDates: Set<Date>
    var currentStreak: Int
    var bestStreak: Int
    
    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
        self.completedDates = []
        self.currentStreak = 0
        self.bestStreak = 0
    }
}