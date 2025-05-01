import SwiftUI
import Charts

struct ScreenTimeView: View {
    @StateObject private var screenTimeManager = ScreenTimeManager()
    @State private var selectedDate = Date()
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time Overview Card
                TimeOverviewCard(
                    dailyTotal: screenTimeManager.getTotalUsageForDate(selectedDate),
                    weeklyData: screenTimeManager.getWeeklyUsage()
                )
                
                // App Usage List
                VStack(alignment: .leading, spacing: 15) {
                    Text("App Usage")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.label))
                    
                    ForEach(screenTimeManager.getUsageForDate(selectedDate)
                        .sorted { $0.duration > $1.duration }
                    ) { usage in
                        AppUsageRow(usage: usage)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: Color(.systemGray4), radius: 5)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Screen Time")
    }
}

struct TimeOverviewCard: View {
    let dailyTotal: TimeInterval
    let weeklyData: [Date: TimeInterval]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Today's Screen Time")
                .font(.headline)
                .foregroundColor(Color(.label))
            
            Text(formatDuration(dailyTotal))
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(Color(.systemBlue))
            
            // Weekly Chart
            Chart {
                ForEach(Array(weeklyData.keys.sorted()), id: \.self) { date in
                    BarMark(
                        x: .value("Day", date, unit: .day),
                        y: .value("Hours", (weeklyData[date] ?? 0) / 3600)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
            }
            .frame(height: 150)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel(format: .dateTime.weekday())
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color(.systemGray4), radius: 5)
    }
}

struct AppUsageRow: View {
    let usage: AppUsage
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.random)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(usage.appName.prefix(1)))
                        .foregroundColor(.white)
                        .font(.headline)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(usage.appName)
                    .font(.headline)
                    .foregroundColor(Color(.label))
                
                Text(formatDuration(usage.duration))
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
            }
            
            Spacer()
            
            CircularProgressView(progress: min(usage.duration / (4 * 3600), 1.0))
                .frame(width: 30, height: 30)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color(.systemBlue), lineWidth: 3)
                .rotationEffect(.degrees(-90))
        }
    }
}

// Helper functions and extensions
func formatDuration(_ duration: TimeInterval) -> String {
    let hours = Int(duration) / 3600
    let minutes = Int(duration) / 60 % 60
    
    if hours > 0 {
        return "\(hours)h \(minutes)m"
    } else {
        return "\(minutes)m"
    }
}

extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0.4...0.8),
            green: .random(in: 0.4...0.8),
            blue: .random(in: 0.4...0.8)
        )
    }
}