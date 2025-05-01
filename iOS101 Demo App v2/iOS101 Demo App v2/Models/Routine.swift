import Foundation

struct RoutineStep: Identifiable, Codable {
    var id = UUID()
    var title: String
    var duration: Int // in seconds
    var isCompleted: Bool = false
}

struct Routine: Identifiable, Codable {
    var id = UUID()
    var title: String
    var steps: [RoutineStep]
    var totalDuration: Int {
        steps.reduce(0) { $0 + $1.duration }
    }
    var isActive: Bool = false
    var currentStepIndex: Int = 0
}