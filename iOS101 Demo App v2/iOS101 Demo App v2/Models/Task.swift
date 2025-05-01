import Foundation
import SwiftUI

enum TaskPriority: Int, Codable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    
    var name: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return Color(.systemBlue)
        case .medium: return Color(.systemOrange)
        case .high: return Color(.systemRed)
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .low: return Color(.systemBlue).opacity(0.2)
        case .medium: return Color(.systemOrange).opacity(0.2)
        case .high: return Color(.systemRed).opacity(0.2)
        }
    }
}

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?
    var priority: TaskPriority
    var notes: String?
    
    init(title: String, 
         isCompleted: Bool = false, 
         dueDate: Date? = nil, 
         priority: TaskPriority = .medium,
         notes: String? = nil) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.dueDate = dueDate
        self.priority = priority
        self.notes = notes
    }
}
