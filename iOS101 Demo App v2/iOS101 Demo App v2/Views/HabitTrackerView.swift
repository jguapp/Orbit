import SwiftUI

struct HabitTrackerView: View {
    @StateObject private var habitManager = HabitManager()
    @State private var showingAddHabit = false
    @State private var newHabitTitle = ""
    @State private var selectedDate = Date()
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.1, green: 0.1, blue: 0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Date Selector
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color(red: 0.15, green: 0.15, blue: 0.25))
                .cornerRadius(16)
                .colorScheme(.dark)
                .tint(.blue)
                .padding(.horizontal)
                
                // Stats Row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        HabitStatCard(
                            title: "Active Habits",
                            value: "\(habitManager.habits.count)",
                            icon: "list.bullet",
                            color: .blue
                        )
                        
                        HabitStatCard(
                            title: "Completed Today",
                            value: "\(habitManager.habits.filter { $0.completedDates.contains(Calendar.current.startOfDay(for: Date())) }.count)",
                            icon: "checkmark.circle",
                            color: .green
                        )
                        
                        HabitStatCard(
                            title: "Best Streak",
                            value: "\(habitManager.habits.map { $0.bestStreak }.max() ?? 0)",
                            icon: "flame.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                }
                .frame(height: 100)
                
                // Habits List
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Habits")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    if habitManager.habits.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "list.bullet.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No habits yet")
                                .foregroundColor(.gray)
                            Text("Add your first habit to start tracking")
                                .font(.caption)
                                .foregroundColor(.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                        )
                        .padding(.horizontal)
                    } else {
                        ForEach(habitManager.habits) { habit in
                            EnhancedHabitRow(
                                habit: habit,
                                date: selectedDate,
                                toggleAction: {
                                    habitManager.toggleHabit(habit, for: selectedDate)
                                },
                                deleteAction: {
                                    habitManager.deleteHabit(habit)
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top)
            
            // Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddHabit = true }) {
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
        .navigationTitle("Habits")
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView(habitManager: habitManager, isPresented: $showingAddHabit)
        }
    }
}

struct EnhancedHabitRow: View {
    let habit: Habit
    let date: Date
    let toggleAction: () -> Void
    let deleteAction: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Completion Button
            Button(action: toggleAction) {
                ZStack {
                    Circle()
                        .stroke(
                            habit.completedDates.contains(Calendar.current.startOfDay(for: date)) ?
                            Color.green : Color.gray.opacity(0.5),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)
                    
                    if habit.completedDates.contains(Calendar.current.startOfDay(for: date)) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    Label("\(habit.currentStreak)d streak", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("Best: \(habit.bestStreak)d")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: deleteAction) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.gray, Color(red: 0.3, green: 0.3, blue: 0.35))
                    .font(.system(size: 20))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
        )
    }
}

struct HabitStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 110, height: 90)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
        )
    }
}

struct AddHabitView: View {
    @ObservedObject var habitManager: HabitManager
    @Binding var isPresented: Bool
    @State private var title = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.2)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    TextField("Habit Title", text: $title)
                        .textFieldStyle(RoutineTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        if !title.isEmpty {
                            habitManager.addHabit(title)
                            isPresented = false
                        }
                    }) {
                        Text("Create Habit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(title.isEmpty)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        HabitTrackerView()
    }
}
