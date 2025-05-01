import SwiftUI

struct FocusStatsView: View {
    @EnvironmentObject private var pomodoroManager: PomodoroManager
    @State private var selectedDate = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Last Session Stats
                VStack(alignment: .leading, spacing: 10) {
                    Text("Last Focus Session")
                        .font(.headline)
                        .foregroundColor(Color(.label))
                    
                    HStack {
                        StatsCard(
                            title: "Duration",
                            value: pomodoroManager.lastSessionDuration,
                            unit: "min"
                        )
                        
                        StatsCard(
                            title: "Completed",
                            value: pomodoroManager.lastSessionDate?.formatted(date: .abbreviated, time: .shortened) ?? "None"
                        )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: Color(.systemGray4), radius: 5)
                
                // Calendar View
                VStack(alignment: .leading, spacing: 10) {
                    Text("Focus Calendar")
                        .font(.headline)
                        .foregroundColor(Color(.label))
                    
                    CalendarView(selectedDate: $selectedDate)
                        .frame(height: 300)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: Color(.systemGray4), radius: 5)
                
                // Streak Information
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current Streak")
                        .font(.headline)
                        .foregroundColor(Color(.label))
                    
                    HStack {
                        StatsCard(
                            title: "Days",
                            value: "\(pomodoroManager.currentStreak)"
                        )
                        
                        StatsCard(
                            title: "Best Streak",
                            value: "\(pomodoroManager.bestStreak)"
                        )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: Color(.systemGray4), radius: 5)
            }
            .padding()
        }
        .navigationTitle("Focus Stats")
        .background(Color(.systemGroupedBackground))
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    var unit: String = ""
    
    init(title: String, value: CustomStringConvertible, unit: String = "") {
        self.title = title
        self.value = String(describing: value)
        self.unit = unit
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color(.secondaryLabel))
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(.label))
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct CalendarView: View {
    @Binding var selectedDate: Date
    @EnvironmentObject private var pomodoroManager: PomodoroManager
    
    var body: some View {
        VStack {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
        }
    }
}

#Preview {
    NavigationView {
        FocusStatsView()
            .environmentObject(PomodoroManager())
    }
}
