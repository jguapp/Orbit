import Foundation

class ADHDToolboxManager: ObservableObject {
    @Published var tips: [ADHDTip] = []
    private let bookmarksKey = "bookmarkedTips"
    
    init() {
        loadTips()
        loadBookmarks()
    }
    
    private func loadTips() {
        tips = [
            ADHDTip(
                title: "Body Doubling",
                description: "Work alongside someone else, either in person or virtually, to help maintain focus and motivation. The presence of another person can help create accountability and structure.",
                category: .focus,
                isBookmarked: false,
                examples: [
                    "Study with a friend at a library",
                    "Join virtual coworking sessions",
                    "Work in a coffee shop with ambient noise"
                ]
            ),
            ADHDTip(
                title: "The 2-Minute Rule",
                description: "If a task takes less than 2 minutes, do it immediately instead of putting it off. This helps prevent the accumulation of small tasks and reduces mental load.",
                category: .taskManagement,
                isBookmarked: false,
                examples: [
                    "Immediately wash dishes after use",
                    "Reply to quick emails right away",
                    "Make your bed in the morning"
                ]
            ),
            ADHDTip(
                title: "Task Chunking",
                description: "Break large tasks into smaller, manageable chunks to reduce overwhelm and make progress more visible.",
                category: .taskManagement,
                isBookmarked: false,
                examples: [
                    "Split essay writing into research, outline, and writing phases",
                    "Break room cleaning into surfaces, floor, and organizing",
                    "Divide project into daily mini-goals"
                ]
            ),
            ADHDTip(
                title: "Time Blocking",
                description: "Assign specific time blocks to tasks and activities to create structure and improve time awareness.",
                category: .timeManagement,
                isBookmarked: false,
                examples: [
                    "9-11 AM: Deep work",
                    "2-3 PM: Email and admin tasks",
                    "4-5 PM: Exercise"
                ]
            ),
            ADHDTip(
                title: "Visual Reminders",
                description: "Place visual cues in your environment to remember important tasks and maintain routines.",
                category: .organization,
                isBookmarked: false,
                examples: [
                    "Sticky notes on bathroom mirror",
                    "Phone wallpaper with goals",
                    "Physical calendar in visible location"
                ]
            ),
            ADHDTip(
                title: "Emotional Temperature Check",
                description: "Regularly assess your emotional state to prevent overwhelm and maintain balance.",
                category: .emotionalRegulation,
                isBookmarked: false,
                examples: [
                    "Use a mood tracking app",
                    "Schedule regular check-ins",
                    "Practice mindfulness exercises"
                ]
            ),
            ADHDTip(
                title: "Morning Routine Anchor",
                description: "Create a consistent morning routine to start your day with structure and momentum.",
                category: .routineBuilding,
                isBookmarked: false,
                examples: [
                    "Drink water first thing",
                    "5-minute stretching routine",
                    "Quick room tidy"
                ]
            ),
            ADHDTip(
                title: "Active Recall",
                description: "Instead of passive reading, actively engage with study material through questioning and summarization.",
                category: .studyTechniques,
                isBookmarked: false,
                examples: [
                    "Create practice questions",
                    "Teach concepts to others",
                    "Draw concept maps"
                ]
            ),
            ADHDTip(
                title: "External Working Memory",
                description: "Use external tools to supplement working memory and reduce cognitive load.",
                category: .organization,
                isBookmarked: false,
                examples: [
                    "Digital task manager",
                    "Voice memos for ideas",
                    "Checklists for routines"
                ]
            ),
            ADHDTip(
                title: "Energy Mapping",
                description: "Schedule tasks according to your natural energy levels throughout the day.",
                category: .timeManagement,
                isBookmarked: false,
                examples: [
                    "Complex tasks during peak energy",
                    "Administrative work during lower energy",
                    "Creative work when most inspired"
                ]
            )
        ]
    }
    
    private func loadBookmarks() {
        if let bookmarkedIds = UserDefaults.standard.stringArray(forKey: bookmarksKey) {
            let idSet = Set(bookmarkedIds)
            tips = tips.map { tip in
                var newTip = tip
                newTip.isBookmarked = idSet.contains(tip.id.uuidString)
                return newTip
            }
        }
    }
    
    func toggleBookmark(for tip: ADHDTip) {
        if let index = tips.firstIndex(where: { $0.id == tip.id }) {
            tips[index].isBookmarked.toggle()
            saveBookmarks()
        }
    }
    
    private func saveBookmarks() {
        let bookmarkedIds = tips.filter { $0.isBookmarked }.map { $0.id.uuidString }
        UserDefaults.standard.set(bookmarkedIds, forKey: bookmarksKey)
    }
}
