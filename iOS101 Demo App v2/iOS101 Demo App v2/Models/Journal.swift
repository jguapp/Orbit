import Foundation

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var mood: Mood
    var dailyPromptResponses: [String: String]
    var weeklyPromptResponses: [String: String]
    var freeformText: String
    
    init(id: UUID = UUID(), 
         date: Date = Date(),
         mood: Mood = .neutral,
         dailyPromptResponses: [String: String] = [:],
         weeklyPromptResponses: [String: String] = [:],
         freeformText: String = "") {
        self.id = id
        self.date = date
        self.mood = mood
        self.dailyPromptResponses = dailyPromptResponses
        self.weeklyPromptResponses = weeklyPromptResponses
        self.freeformText = freeformText
    }
}

enum Mood: String, Codable, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case neutral = "Neutral"
    case low = "Low"
    case poor = "Poor"
    
    var emoji: String {
        switch self {
        case .excellent: return "🌟"
        case .good: return "😊"
        case .neutral: return "😐"
        case .low: return "😕"
        case .poor: return "😢"
        }
    }
    
    var color: String {
        switch self {
        case .excellent: return "purple"
        case .good: return "blue"
        case .neutral: return "gray"
        case .low: return "orange"
        case .poor: return "red"
        }
    }
}