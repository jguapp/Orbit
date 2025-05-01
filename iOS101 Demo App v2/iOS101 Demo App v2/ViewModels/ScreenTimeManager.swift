import Foundation

struct AppUsage: Codable, Identifiable {
    var id = UUID()
    let appName: String
    var duration: TimeInterval
    let date: Date
}

class ScreenTimeManager: ObservableObject {
    @Published private(set) var dailyUsage: [AppUsage] = []
    private let savePath = FileManager.documentsDirectory.appendingPathComponent("screentime")
    
    init() {
        loadData()
        // Add some sample data if none exists
        if dailyUsage.isEmpty {
            addSampleData()
        }
    }
    
    func recordUsage(appName: String, duration: TimeInterval) {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let index = dailyUsage.firstIndex(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: today) && 
            $0.appName == appName 
        }) {
            dailyUsage[index].duration += duration
        } else {
            let usage = AppUsage(appName: appName, duration: duration, date: today)
            dailyUsage.append(usage)
        }
        
        saveData()
    }
    
    func getUsageForDate(_ date: Date) -> [AppUsage] {
        dailyUsage.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func getTotalUsageForDate(_ date: Date) -> TimeInterval {
        getUsageForDate(date).reduce(0) { $0 + $1.duration }
    }
    
    func getWeeklyUsage() -> [Date: TimeInterval] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var usage: [Date: TimeInterval] = [:]
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            usage[date] = getTotalUsageForDate(date)
        }
        
        return usage
    }
    
    private func saveData() {
        do {
            let data = try JSONEncoder().encode(dailyUsage)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save screen time data: \(error.localizedDescription)")
        }
    }
    
    private func loadData() {
        do {
            let data = try Data(contentsOf: savePath)
            dailyUsage = try JSONDecoder().decode([AppUsage].self, from: data)
        } catch {
            dailyUsage = []
        }
    }
    
    private func addSampleData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let apps = ["Instagram", "Twitter", "Messages", "Mail", "Safari"]
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            for app in apps {
                let randomDuration = TimeInterval.random(in: 300...7200) // 5 minutes to 2 hours
                let usage = AppUsage(appName: app, duration: randomDuration, date: date)
                dailyUsage.append(usage)
            }
        }
        
        saveData()
    }
}