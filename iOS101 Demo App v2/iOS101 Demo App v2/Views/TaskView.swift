import SwiftUI

struct TaskView: View {
    @StateObject private var taskManager = TaskManager()
    @State private var newTaskTitle = ""
    @State private var showingAddTask = false
    @State private var showingTaskDetails = false
    @State private var selectedTask: Task?
    @State private var searchText = ""
    @State private var selectedDate: Date = Date()
    @State private var viewMode: ViewMode = .list
    
    enum ViewMode {
        case list
        case calendar
    }
    
    private var filteredTasks: [Task] {
        let filtered = taskManager.tasks.filter { task in
            let matchesSearch = searchText.isEmpty || 
                task.title.localizedCaseInsensitiveContains(searchText)
            
            if viewMode == .calendar, let dueDate = task.dueDate {
                return matchesSearch && Calendar.current.isDate(dueDate, inSameDayAs: selectedDate)
            }
            
            return matchesSearch
        }
        
        return filtered.sorted { (task1, task2) in
            if task1.priority.rawValue != task2.priority.rawValue {
                return task1.priority.rawValue > task2.priority.rawValue
            }
            if let date1 = task1.dueDate, let date2 = task2.dueDate {
                return date1 < date2
            }
            return task1.createdAt < task2.createdAt
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search tasks", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(10)
                    .background(Color(red: 0.15, green: 0.15, blue: 0.25))
                    .cornerRadius(12)
                    
                    Picker("View Mode", selection: $viewMode) {
                        Image(systemName: "list.bullet")
                            .tag(ViewMode.list)
                        Image(systemName: "calendar")
                            .tag(ViewMode.calendar)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 100)
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(["Total", "High Priority", "Due Today", "Completed"], id: \.self) { stat in
                            TaskStatCard(
                                title: stat,
                                count: getStatCount(for: stat),
                                color: getStatColor(for: stat)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 80)
                
                if viewMode == .calendar {
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding(12)
                    .background(Color(red: 0.15, green: 0.15, blue: 0.25))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                VStack(spacing: 8) {
                    if filteredTasks.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No tasks found")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ForEach(filteredTasks) { task in
                            TaskRowView(task: task,
                                onToggle: { taskManager.toggleTask(task) },
                                onDelete: { taskManager.deleteTask(task) },
                                onTap: {
                                    selectedTask = task
                                    showingTaskDetails = true
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddTask = true }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .shadow(color: .purple.opacity(0.3), radius: 10)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .padding([.trailing, .bottom], 24)
                }
            }
        }
        .navigationTitle("Tasks")
        .sheet(isPresented: $showingAddTask) {
            EnhancedAddTaskView(taskManager: taskManager, isPresented: $showingAddTask)
        }
        .sheet(item: $selectedTask) { task in
            EnhancedTaskDetailView(task: task, taskManager: taskManager)
        }
    }
    
    private func getStatCount(for stat: String) -> Int {
        switch stat {
        case "Total":
            return taskManager.tasks.count
        case "High Priority":
            return taskManager.tasks.filter { $0.priority == .high }.count
        case "Due Today":
            return taskManager.tasks.filter {
                guard let dueDate = $0.dueDate else { return false }
                return Calendar.current.isDateInToday(dueDate)
            }.count
        case "Completed":
            return taskManager.tasks.filter { $0.isCompleted }.count
        default:
            return 0
        }
    }
    
    private func getStatColor(for stat: String) -> Color {
        switch stat {
        case "High Priority":
            return Color(.systemRed)
        case "Due Today":
            return Color(.systemOrange)
        case "Completed":
            return Color(.systemGreen)
        default:
            return Color(.systemBlue)
        }
    }
}

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .stroke(task.isCompleted ? Color.green : Color.gray.opacity(0.5), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if task.isCompleted {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .gray : .white)
                        .font(.system(.body, design: .rounded))
                    
                    if let dueDate = task.dueDate {
                        Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(task.priority.name)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(task.priority.backgroundColor)
                    .foregroundColor(task.priority.color)
                    .clipShape(Capsule())
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray, Color(red: 0.3, green: 0.3, blue: 0.35))
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                    .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
            )
        }
    }
}

struct TaskStatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text("\(count)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
        }
        .frame(width: 90)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
        )
    }
}

struct EnhancedAddTaskView: View {
    @ObservedObject var taskManager: TaskManager
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var dueDate: Date = Date()
    @State private var includeDueDate = false
    @State private var priority: TaskPriority = .medium
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                Form {
                    Section(header: Text("Task Details")) {
                        TextField("Task title", text: $title)
                        
                        Picker("Priority", selection: $priority) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                HStack {
                                    Circle()
                                        .fill(priority.color)
                                        .frame(width: 10, height: 10)
                                    Text(priority.name)
                                }
                                .tag(priority)
                            }
                        }
                        
                        Toggle("Set Due Date", isOn: $includeDueDate)
                        
                        if includeDueDate {
                            DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        }
                    }
                    
                    Section(header: Text("Notes")) {
                        TextEditor(text: $notes)
                            .frame(height: 100)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Task")
            .navigationBarItems(
                leading: Button("Cancel") { isPresented = false },
                trailing: Button("Add") {
                    if !title.isEmpty {
                        taskManager.addTask(
                            title,
                            dueDate: includeDueDate ? dueDate : nil,
                            priority: priority,
                            notes: notes.isEmpty ? nil : notes
                        )
                        isPresented = false
                    }
                }
                .disabled(title.isEmpty)
            )
        }
    }
}

struct EnhancedTaskDetailView: View {
    let task: Task
    @ObservedObject var taskManager: TaskManager
    @Environment(\.presentationMode) var presentationMode
    @State private var editedTitle: String
    @State private var editedDueDate: Date
    @State private var editedPriority: TaskPriority
    @State private var editedNotes: String
    @State private var includeDueDate: Bool
    @State private var isEditing = false
    
    init(task: Task, taskManager: TaskManager) {
        self.task = task
        self.taskManager = taskManager
        _editedTitle = State(initialValue: task.title)
        _editedDueDate = State(initialValue: task.dueDate ?? Date())
        _editedPriority = State(initialValue: task.priority)
        _editedNotes = State(initialValue: task.notes ?? "")
        _includeDueDate = State(initialValue: task.dueDate != nil)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                Form {
                    Section(header: Text("Task Details")) {
                        if isEditing {
                            TextField("Task title", text: $editedTitle)
                        } else {
                            Text(task.title)
                                .foregroundColor(Color(.label))
                        }
                        
                        if isEditing {
                            Picker("Priority", selection: $editedPriority) {
                                ForEach(TaskPriority.allCases, id: \.self) { priority in
                                    HStack {
                                        Circle()
                                            .fill(priority.color)
                                            .frame(width: 10, height: 10)
                                        Text(priority.name)
                                    }
                                    .tag(priority)
                                }
                            }
                        } else {
                            HStack {
                                Text("Priority")
                                Spacer()
                                Circle()
                                    .fill(task.priority.color)
                                    .frame(width: 10, height: 10)
                                Text(task.priority.name)
                            }
                        }
                        
                        if isEditing {
                            Toggle("Set Due Date", isOn: $includeDueDate)
                            
                            if includeDueDate {
                                DatePicker("Due Date", selection: $editedDueDate, displayedComponents: [.date, .hourAndMinute])
                            }
                        } else if let dueDate = task.dueDate {
                            HStack {
                                Text("Due Date")
                                Spacer()
                                Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                            }
                        }
                    }
                    
                    Section(header: Text("Notes")) {
                        if isEditing {
                            TextEditor(text: $editedNotes)
                                .frame(height: 100)
                        } else {
                            Text(task.notes ?? "No notes")
                                .foregroundColor(task.notes == nil ? Color(.secondaryLabel) : Color(.label))
                        }
                    }
                    
                    Section {
                        Button(action: {
                            taskManager.toggleTask(task)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                Text(task.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                            }
                            .foregroundColor(task.isCompleted ? Color(.systemGreen) : Color(.label))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Task Details")
            .navigationBarItems(
                trailing: Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        taskManager.updateTask(
                            task,
                            newTitle: editedTitle,
                            newDueDate: includeDueDate ? editedDueDate : nil,
                            newPriority: editedPriority,
                            newNotes: editedNotes.isEmpty ? nil : editedNotes
                        )
                    }
                    isEditing.toggle()
                }
            )
        }
    }
}
