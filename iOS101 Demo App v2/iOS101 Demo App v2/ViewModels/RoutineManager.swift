import Foundation

class RoutineManager: ObservableObject {
    @Published private(set) var routines: [Routine] = []
    @Published var activeRoutine: Routine?
    @Published var currentTime: Int = 0
    private var timer: Timer?
    
    private let savePath = FileManager.documentsDirectory.appendingPathComponent("routines")
    
    init() {
        loadRoutines()
    }
    
    func addRoutine(_ routine: Routine) {
        routines.append(routine)
        saveRoutines()
    }
    
    func deleteRoutine(_ routine: Routine) {
        routines.removeAll { $0.id == routine.id }
        saveRoutines()
    }
    
    func startRoutine(_ routine: Routine) {
        var updatedRoutine = routine
        updatedRoutine.isActive = true
        updatedRoutine.currentStepIndex = 0
        updatedRoutine.steps = routine.steps.map { var step = $0; step.isCompleted = false; return step }
        activeRoutine = updatedRoutine
        currentTime = updatedRoutine.steps[0].duration
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func pauseRoutine() {
        timer?.invalidate()
    }
    
    func resumeRoutine() {
        guard activeRoutine != nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func stopRoutine() {
        timer?.invalidate()
        timer = nil
        activeRoutine = nil
        currentTime = 0
    }
    
    private func updateTimer() {
        guard var routine = activeRoutine else { return }
        
        if currentTime > 0 {
            currentTime -= 1
        } else {
            // Current step is complete
            routine.steps[routine.currentStepIndex].isCompleted = true
            
            // Move to next step
            if routine.currentStepIndex < routine.steps.count - 1 {
                routine.currentStepIndex += 1
                currentTime = routine.steps[routine.currentStepIndex].duration
            } else {
                // Routine complete
                stopRoutine()
                return
            }
        }
        
        activeRoutine = routine
    }
    
    private func saveRoutines() {
        do {
            let data = try JSONEncoder().encode(routines)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save routines: \(error.localizedDescription)")
        }
    }
    
    private func loadRoutines() {
        do {
            let data = try Data(contentsOf: savePath)
            routines = try JSONDecoder().decode([Routine].self, from: data)
        } catch {
            routines = []
        }
    }
}