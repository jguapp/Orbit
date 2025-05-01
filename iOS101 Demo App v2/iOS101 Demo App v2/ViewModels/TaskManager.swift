import Foundation

class TaskManager: ObservableObject {
    @Published private(set) var tasks: [Task] = []
    private let savePath = FileManager.documentsDirectory.appendingPathComponent("tasks")
    
    init() {
        loadTasks()
    }
    
    func addTask(_ title: String, dueDate: Date? = nil, priority: TaskPriority = .medium, notes: String? = nil) {
        let task = Task(title: title, dueDate: dueDate, priority: priority, notes: notes)
        tasks.append(task)
        saveTasks()
    }
    
    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func updateTask(_ task: Task, newTitle: String, newDueDate: Date?, newPriority: TaskPriority, newNotes: String?) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = newTitle
            tasks[index].dueDate = newDueDate
            tasks[index].priority = newPriority
            tasks[index].notes = newNotes
            saveTasks()
        }
    }
    
    private func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save tasks: \(error.localizedDescription)")
        }
    }
    
    private func loadTasks() {
        do {
            let data = try Data(contentsOf: savePath)
            tasks = try JSONDecoder().decode([Task].self, from: data)
        } catch {
            tasks = []
        }
    }
}

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
