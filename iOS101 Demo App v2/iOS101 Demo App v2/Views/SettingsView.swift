import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var pomodoroManager: PomodoroManager
    @State private var workMinutes: Double
    @State private var breakMinutes: Double
    @State private var showSaveAlert = false
    @AppStorage("selectedTheme") private var selectedTheme = 0
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("dailyFocusGoal") private var dailyFocusGoal = 4
    
    let themes = ["Cosmic", "Ocean", "Forest", "Desert"]
    
    init() {
        _workMinutes = State(initialValue: Double(UserDefaults.standard.integer(forKey: "pomodoroLength")))
        _breakMinutes = State(initialValue: Double(UserDefaults.standard.integer(forKey: "breakLength")))
    }
    
    var body: some View {
        Form {
            Section("Timer Settings") {
                VStack(alignment: .leading) {
                    Text("Focus Session Length: \(Int(workMinutes)) minutes")
                    Slider(value: $workMinutes, in: 1...60, step: 1)
                }
                
                VStack(alignment: .leading) {
                    Text("Break Length: \(Int(breakMinutes)) minutes")
                    Slider(value: $breakMinutes, in: 1...30, step: 1)
                }
                
                Stepper("Daily Focus Sessions Goal: \(dailyFocusGoal)", value: $dailyFocusGoal, in: 1...12)
                
                Button("Save Changes") {
                    pomodoroManager.workMinutes = Int(workMinutes)
                    pomodoroManager.breakMinutes = Int(breakMinutes)
                    pomodoroManager.reset()
                    showSaveAlert = true
                }
                .foregroundColor(.purple)
            }
            
            Section("Appearance") {
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(0..<themes.count, id: \.self) { index in
                        Text(themes[index])
                    }
                }
            }
            
            Section("Notifications") {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, newValue in
                        if newValue {
                            requestNotificationPermission()
                        }
                    }
                
                Toggle("Sound Effects", isOn: $soundEnabled)
            }
            
            Section("Data Management") {
                Button("Export Statistics") {
                    exportStats()
                }
                .foregroundColor(.blue)
                
                Button("Clear All Data") {
                    clearAllData()
                }
                .foregroundColor(.red)
            }
            
            Section("About") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Orbit")
                        .font(.headline)
                    Text("Version 1.0")
                        .foregroundColor(.gray)
                    
                    Link("Privacy Policy", destination: URL(string: "https://your-app-website.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://your-app-website.com/terms")!)
                    
                    Text("Made with ❤️ by Your Team")
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                }
            }
        }
        .navigationTitle("Settings")
        .alert("Settings Saved", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your timer settings have been updated.")
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    private func exportStats() {
        // Implementation for exporting statistics
        // This would typically involve creating a CSV or JSON file
        // and sharing it via a share sheet
    }
    
    private func clearAllData() {
        // Implementation for clearing all user data
        // This would typically show a confirmation alert first
        UserDefaults.standard.reset()
    }
}

extension UserDefaults {
    func reset() {
        let dictionary = self.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            self.removeObject(forKey: key)
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(PomodoroManager())
    }
}
