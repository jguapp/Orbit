//
//  ContentView.swift
//  iOS101 Demo App v2
//
//  Created by joel on 4/23/25.
//

import SwiftUI
import UserNotifications
import AVFoundation

struct ContentView: View {
    @StateObject private var pomodoroManager = PomodoroManager()
    @StateObject private var soundManager = SoundManager()
    @State private var editedWorkTime: Int = UserDefaults.standard.integer(forKey: "pomodoroLength")
    @State private var editedBreakTime: Int = UserDefaults.standard.integer(forKey: "breakLength")
    @State private var showingTimeEditor = false
    @State private var editingBreakTime = false
    @StateObject private var taskManager = TaskManager()
    @State private var newTaskTitle = ""
    @State private var showCustomWorkTimePicker = false
    @State private var showCustomBreakTimePicker = false
    @State private var customWorkTime = ""
    @State private var customBreakTime = ""
    @State private var showingSoundPicker = false
    @State private var volume: Double = 0.5

    var body: some View {
        NavigationView {
            ZStack {
                // Space-themed gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2), // Deep space blue
                        Color(red: 0.2, green: 0.1, blue: 0.3), // Cosmic purple
                        Color(red: 0.1, green: 0.0, blue: 0.2)  // Dark nebula
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Stars effect
                GeometryReader { geometry in
                    ZStack {
                        ForEach(0..<50) { _ in
                            Circle()
                                .fill(Color.white)
                                .frame(width: CGFloat.random(in: 1...3))
                                .position(
                                    x: CGFloat.random(in: 0...geometry.size.width),
                                    y: CGFloat.random(in: 0...geometry.size.height)
                                )
                                .opacity(Double.random(in: 0.2...0.7))
                        }
                    }
                }
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Mode Toggle
                        Button(action: { pomodoroManager.toggleMode() }) {
                            Text(pomodoroManager.isBreakTime ? "Break Time" : "Focus Time")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(
                                            pomodoroManager.isBreakTime ?
                                            LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing) :
                                            LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .shadow(color: pomodoroManager.isBreakTime ? .teal.opacity(0.5) : .purple.opacity(0.5), radius: 10)
                                )
                        }
                        .padding(.top, 10)
                        
                        // Timer Display
                        ZStack {
                            // Outer orbital ring
                            Circle()
                                .stroke(
                                    pomodoroManager.isBreakTime ?
                                    LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing),
                                    lineWidth: 20
                                )
                                .frame(width: 280, height: 280)
                            
                            // Inner glow
                            Circle()
                                .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                                .frame(width: 260, height: 260)
                                .shadow(color: pomodoroManager.isBreakTime ? .teal.opacity(0.3) : .purple.opacity(0.3), radius: 20)
                            
                            VStack(spacing: 5) {
                                Text(String(format: "%02d:%02d", pomodoroManager.minutes, pomodoroManager.seconds))
                                    .font(.system(size: 60, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: pomodoroManager.isBreakTime ? .teal.opacity(0.5) : .purple.opacity(0.5), radius: 10)
                                
                                Button("Edit Time") {
                                    editedWorkTime = pomodoroManager.workMinutes
                                    editedBreakTime = pomodoroManager.breakMinutes
                                    showingTimeEditor = true
                                }
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Add Sound Control Button after the timer display
                        Button(action: { showingSoundPicker = true }) {
                            HStack {
                                Image(systemName: soundManager.isPlaying ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                Text(soundManager.selectedSound.rawValue)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(colors: [.teal, .blue], startPoint: .leading, endPoint: .trailing)
                                    )
                                    .shadow(color: .teal.opacity(0.5), radius: 10)
                            )
                        }
                        
                        // Volume Slider (only show when sound is playing)
                        if soundManager.isPlaying {
                            HStack {
                                Image(systemName: "speaker.fill")
                                Slider(value: $volume, in: 0...1) { _ in
                                    soundManager.setVolume(Float(volume))
                                }
                                Image(systemName: "speaker.wave.2.fill")
                            }
                            .padding(.horizontal)
                            .foregroundColor(.white)
                        }
                        
                        // Timer Controls
                        HStack(spacing: 20) {
                            CosmicButton(
                                title: pomodoroManager.isActive ? "Pause" : "Start",
                                color: pomodoroManager.isBreakTime ? .teal : .purple
                            ) {
                                if pomodoroManager.isActive {
                                    pomodoroManager.pause()
                                } else {
                                    pomodoroManager.start()
                                }
                            }
                            
                            CosmicButton(title: "Reset", color: .red) {
                                pomodoroManager.reset()
                            }
                        }
                        
                        // Task Section (reduced height)
                        VStack(alignment: .center, spacing: 10) {
                            Text("Mission Tasks")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack {
                                TextField("Add a new task", text: $newTaskTitle)
                                    .textFieldStyle(CosmicTextFieldStyle())
                                    .frame(maxWidth: .infinity)
                                
                                Button(action: {
                                    if !newTaskTitle.isEmpty {
                                        taskManager.addTask(newTaskTitle)
                                        newTaskTitle = ""
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.cyan)
                                }
                                .padding(.leading, 8)
                            }
                            .padding(.horizontal, 8)
                            
                            // Show only up to 3 tasks
                            VStack(spacing: 8) {
                                ForEach(Array(taskManager.tasks.prefix(3))) { task in
                                    HStack {
                                        Button(action: { taskManager.toggleTask(task) }) {
                                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(task.isCompleted ? .green : .gray)
                                                .font(.title3)
                                        }
                                        
                                        Text(task.title)
                                            .strikethrough(task.isCompleted)
                                            .foregroundColor(task.isCompleted ? .gray : .white)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Button(action: { taskManager.deleteTask(task) }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red.opacity(0.7))
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                                            .shadow(color: Color.purple.opacity(0.2), radius: 5, y: 3)
                                    )
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                        .frame(maxHeight: 200)

                        Spacer(minLength: 0)
                    }
                    
                    VStack {
                        Spacer()
                        // Navigation buttons
                        HStack(spacing: 4) {
                            NavigationLink(destination: TaskView()) {
                                NavButton(imageName: "checklist", title: "Tasks")
                            }
                            
                            NavigationLink(destination: RoutineView()) {
                                NavButton(imageName: "clock", title: "Routines")
                            }
                            
                            NavigationLink(destination: HabitTrackerView()) {
                                NavButton(imageName: "list.bullet", title: "Habits")
                            }
                            
                            NavigationLink(destination: JournalView()) {
                                NavButton(imageName: "book", title: "Log")
                            }
                            
                            NavigationLink(destination: ScreenTimeView()) {
                                NavButton(imageName: "hourglass", title: "Time")
                            }
                            
                            NavigationLink(destination: FocusStatsView().environmentObject(pomodoroManager)) {
                                NavButton(imageName: "chart.bar", title: "Stats")
                            }
                            
                            NavigationLink(destination: ADHDToolboxView()) {
                                NavButton(imageName: "brain", title: "Tools")
                            }
                            
                            NavigationLink(destination: SettingsView().environmentObject(pomodoroManager)) {
                                NavButton(imageName: "gear", title: "Settings")
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                                .shadow(color: Color.black.opacity(0.2), radius: 10)
                        )
                        .padding(.horizontal, 6)
                        .padding(.bottom, 16)
                        .padding(.top, 1)
                    }
                    .padding(.bottom, 8)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles.circle.fill")
                            .font(.title)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("ORBIT")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            }
            .alert(isPresented: $pomodoroManager.showingAlert) {
                Alert(
                    title: Text(pomodoroManager.isBreakTime ? "Break Time Started" : "Focus Time Started"),
                    message: Text(pomodoroManager.isBreakTime ? "Time to recharge!" : "Let's focus!"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showingTimeEditor) {
                NavigationView {
                    ZStack {
                        // Space-themed background
                        Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea()
                        
                        ScrollView {
                            VStack(spacing: 25) {
                                // Work Time Presets
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Focus Duration")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 10) {
                                        ForEach([25, 30, 45, 60], id: \.self) { minutes in
                                            TimePresetButton(
                                                minutes: minutes,
                                                isSelected: editedWorkTime == minutes,
                                                color: .purple
                                            ) {
                                                showCustomWorkTimePicker = false
                                                editedWorkTime = minutes
                                            }
                                        }
                                    }
                                    
                                    TimePresetButton(
                                        minutes: 0,
                                        isSelected: showCustomWorkTimePicker,
                                        color: .purple
                                    ) {
                                        showCustomWorkTimePicker = true
                                        customWorkTime = "\(editedWorkTime)"
                                    }
                                    .overlay(
                                        Text("Custom")
                                            .foregroundColor(showCustomWorkTimePicker ? .white : .purple)
                                    )
                                    
                                    if showCustomWorkTimePicker {
                                        HStack {
                                            TextField("Enter minutes", text: $customWorkTime)
                                                .keyboardType(.numberPad)
                                                .textFieldStyle(CosmicTextFieldStyle())
                                                .onChange(of: customWorkTime) { newValue in
                                                    if let minutes = Int(newValue), minutes > 0 {
                                                        editedWorkTime = min(minutes, 180) // Max 3 hours
                                                    }
                                                }
                                            
                                            Text("min")
                                                .foregroundColor(.white)
                                        }
                                        .padding(.top, 5)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(15)
                                
                                // Break Time Presets
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Break Duration")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 10) {
                                        ForEach([5, 10, 15, 20], id: \.self) { minutes in
                                            TimePresetButton(
                                                minutes: minutes,
                                                isSelected: editedBreakTime == minutes,
                                                color: .teal
                                            ) {
                                                showCustomBreakTimePicker = false
                                                editedBreakTime = minutes
                                            }
                                        }
                                    }
                                    
                                    TimePresetButton(
                                        minutes: 0,
                                        isSelected: showCustomBreakTimePicker,
                                        color: .teal
                                    ) {
                                        showCustomBreakTimePicker = true
                                        customBreakTime = "\(editedBreakTime)"
                                    }
                                    .overlay(
                                        Text("Custom")
                                            .foregroundColor(showCustomBreakTimePicker ? .white : .teal)
                                    )
                                    
                                    if showCustomBreakTimePicker {
                                        HStack {
                                            TextField("Enter minutes", text: $customBreakTime)
                                                .keyboardType(.numberPad)
                                                .textFieldStyle(CosmicTextFieldStyle())
                                                .onChange(of: customBreakTime) { newValue in
                                                    if let minutes = Int(newValue), minutes > 0 {
                                                        editedBreakTime = min(minutes, 60) // Max 1 hour
                                                    }
                                                }
                                            
                                            Text("min")
                                                .foregroundColor(.white)
                                        }
                                        .padding(.top, 5)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(15)
                            }
                            .padding()
                        }
                    }
                    .navigationTitle("Set Timer Durations")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingTimeEditor = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                pomodoroManager.workMinutes = editedWorkTime
                                pomodoroManager.breakMinutes = editedBreakTime
                                pomodoroManager.reset()
                                showingTimeEditor = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingSoundPicker) {
                NavigationView {
                    List(SoundManager.AmbientSound.allCases, id: \.self) { sound in
                        Button(action: {
                            soundManager.selectedSound = sound
                            if sound == .none {
                                soundManager.stopSound()
                            } else {
                                soundManager.playSound()
                            }
                            showingSoundPicker = false
                        }) {
                            HStack {
                                Text(sound.rawValue)
                                Spacer()
                                if sound == soundManager.selectedSound {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .navigationTitle("Choose Ambient Sound")
                    .navigationBarItems(trailing: Button("Done") {
                        showingSoundPicker = false
                    })
                }
                .presentationDetents([.medium])
            }
        }
        .onChange(of: pomodoroManager.isActive) { _, isActive in
            // Automatically stop sound when timer is stopped
            if !isActive {
                soundManager.stopSound()
            }
        }
    }
}

// Custom Components with cosmic styling
struct CosmicButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 100)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [color, color.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: color.opacity(0.5), radius: 8, y: 3)
        }
    }
}

struct CosmicTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                    .shadow(color: Color.black.opacity(0.2), radius: 5, y: 3)
            )
            .foregroundColor(.white)
            .accentColor(.cyan)
    }
}

struct CosmicTaskRow: View {
    let task: Task
    let toggleAction: () -> Void
    let deleteAction: () -> Void
    
    var body: some View {
        HStack {
            Button(action: toggleAction) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .gray : .white)
            
            Spacer()
            
            Button(action: deleteAction) {
                Image(systemName: "trash")
                    .foregroundColor(.red.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                .shadow(color: Color.purple.opacity(0.2), radius: 5, y: 3)
        )
    }
}

struct TimePresetButton: View {
    let minutes: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(minutes > 0 ? "\(minutes)" : "")
                .font(.headline)
                .foregroundColor(isSelected ? .white : color)
                .frame(minWidth: 44)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? color : Color.white.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

// Add this new component for consistent navigation buttons
struct NavButton: View {
    let imageName: String
    let title: String
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: imageName)
                .font(.system(size: 20))
                .frame(height: 20)
            Text(title)
                .font(.system(size: 11))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundColor(.cyan)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

#Preview {
    ContentView()
}
