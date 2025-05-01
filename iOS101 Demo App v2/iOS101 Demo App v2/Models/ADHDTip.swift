import Foundation

struct ADHDTip: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let category: Category
    var isBookmarked: Bool
    let examples: [String]?
    
    enum Category: String, Codable, CaseIterable {
        case taskManagement = "Task Management"
        case focus = "Focus Strategies"
        case timeManagement = "Time Management"
        case organization = "Organization"
        case emotionalRegulation = "Emotional Regulation"
        case routineBuilding = "Routine Building"
        case studyTechniques = "Study Techniques"
        
        var icon: String {
            switch self {
            case .taskManagement: return "checklist"
            case .focus: return "brain.head.profile"
            case .timeManagement: return "clock"
            case .organization: return "folder"
            case .emotionalRegulation: return "heart"
            case .routineBuilding: return "calendar"
            case .studyTechniques: return "book"
            }
        }
    }
}
