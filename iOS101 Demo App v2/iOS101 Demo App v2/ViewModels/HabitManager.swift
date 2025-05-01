import Foundation

class HabitManager: ObservableObject {
    @Published var habits: [Habit] {
        didSet {
            saveHabits()
        }
    }
    
    init() {
        self.habits = []
        loadHabits()
    }
    
    func addHabit(_ title: String) {
        let habit = Habit(title: title)
        habits.append(habit)
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
    }
    
    func toggleHabit(_ habit: Habit, for date: Date) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            
            var updatedHabit = habit
            if updatedHabit.completedDates.contains(startOfDay) {
                updatedHabit.completedDates.remove(startOfDay)
            } else {
                updatedHabit.completedDates.insert(startOfDay)
            }
            
            updateStreak(&updatedHabit)
            habits[index] = updatedHabit
        }
    }
    
    private func updateStreak(_ habit: inout Habit) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var currentStreak = 0
        var date = today
        
        while habit.completedDates.contains(date) {
            currentStreak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previousDay
        }
        
        habit.currentStreak = currentStreak
        habit.bestStreak = max(habit.bestStreak, currentStreak)
    }
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: "habits")
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: "habits"),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
}