import Foundation

class JournalManager: ObservableObject {
    @Published var entries: [JournalEntry] = []
    
    let dailyPrompts = [
        "What worked well today?",
        "What distracted me today?",
        "What did I learn today?",
        "What am I grateful for today?",
        "What could I have done better?"
    ]
    
    let weeklyPrompts = [
        "What were my main achievements this week?",
        "What challenges did I face?",
        "What habits helped my productivity?",
        "What are my goals for next week?",
        "How can I improve my focus?"
    ]
    
    init() {
        loadEntries()
    }
    
    func addEntry(_ entry: JournalEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func updateEntry(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            saveEntries()
        }
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    func getEntry(for date: Date) -> JournalEntry? {
        let calendar = Calendar.current
        return entries.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "journalEntries")
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "journalEntries"),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            entries = decoded
        }
    }
}