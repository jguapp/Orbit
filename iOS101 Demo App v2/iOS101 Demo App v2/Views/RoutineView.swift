import SwiftUI

struct RoutineView: View {
    @StateObject private var routineManager = RoutineManager()
    @State private var showingAddRoutine = false
    @State private var selectedRoutine: Routine?
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.1, green: 0.1, blue: 0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Active Routine Section
                if let activeRoutine = routineManager.activeRoutine {
                    ActiveRoutineCard(
                        routine: activeRoutine,
                        currentTime: routineManager.currentTime,
                        onStop: { routineManager.stopRoutine() }
                    )
                    .padding(.horizontal)
                }
                
                // Routines List
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Your Routines")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if routineManager.routines.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "clock.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No routines yet")
                                .foregroundColor(.gray)
                            Text("Create your first routine to get started")
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
                        ForEach(routineManager.routines) { routine in
                            RoutineCard(routine: routine) {
                                routineManager.startRoutine(routine)
                            }
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
                    Button(action: { showingAddRoutine = true }) {
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
        .navigationTitle("Routines")
        .sheet(isPresented: $showingAddRoutine) {
            AddRoutineView(routineManager: routineManager)
        }
    }
}

struct ActiveRoutineCard: View {
    let routine: Routine
    let currentTime: Int
    let onStop: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Timer Display
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 4) {
                    Text(timeString(from: currentTime))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(routine.title)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Current Step
            Text("Current Step: \(routine.steps[routine.currentStepIndex].title)")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.white)
            
            // Progress Indicators
            HStack(spacing: 6) {
                ForEach(0..<routine.steps.count, id: \.self) { index in
                    Circle()
                        .fill(index < routine.currentStepIndex ? Color.green :
                              index == routine.currentStepIndex ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            // Stop Button
            Button(action: onStop) {
                Text("Stop")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 120)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.red.opacity(0.8))
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                .shadow(color: Color.black.opacity(0.2), radius: 10)
        )
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct RoutineCard: View {
    let routine: Routine
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.title)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("\(routine.steps.count) steps · \(timeString(from: routine.totalDuration))")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: onStart) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Step Progress
            HStack(spacing: 4) {
                ForEach(routine.steps) { step in
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.25))
                .shadow(color: Color.black.opacity(0.2), radius: 5)
        )
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        return "\(minutes) min"
    }
}

struct AddRoutineView: View {
    @ObservedObject var routineManager: RoutineManager
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var steps: [RoutineStep] = []
    @State private var showingAddStep = false
    @State private var newStepTitle = ""
    @State private var newStepDuration = 5
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.2)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    TextField("Routine Title", text: $title)
                        .textFieldStyle(RoutineTextFieldStyle())
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Steps")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        if steps.isEmpty {
                            Text("Add steps to your routine")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(steps) { step in
                                HStack {
                                    Text(step.title)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(step.duration / 60) min")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(red: 0.15, green: 0.15, blue: 0.25))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                            .onDelete { indexSet in
                                steps.remove(atOffsets: indexSet)
                            }
                        }
                        
                        Button(action: { showingAddStep = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Step")
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.15, green: 0.15, blue: 0.25))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        if !steps.isEmpty {
                            Text("Total Duration: \(steps.reduce(0) { $0 + ($1.duration / 60) }) minutes")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let routine = Routine(title: title, steps: steps)
                        routineManager.addRoutine(routine)
                        dismiss()
                    }
                    .disabled(title.isEmpty || steps.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingAddStep) {
            AddStepView(
                title: $newStepTitle,
                duration: $newStepDuration,
                onSave: {
                    let step = RoutineStep(
                        title: newStepTitle,
                        duration: newStepDuration * 60
                    )
                    steps.append(step)
                    newStepTitle = ""
                    newStepDuration = 5
                    showingAddStep = false
                }
            )
        }
    }
}

struct AddStepView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var title: String
    @Binding var duration: Int
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.2)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    TextField("Step Title", text: $title)
                        .textFieldStyle(RoutineTextFieldStyle())
                    
                    HStack {
                        Text("Duration:")
                            .foregroundColor(.white)
                        
                        Stepper(
                            "\(duration) minutes",
                            value: $duration,
                            in: 1...60
                        )
                        .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color(red: 0.15, green: 0.15, blue: 0.25))
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add Step")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { onSave() }
                        .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct RoutineTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(red: 0.15, green: 0.15, blue: 0.25))
            .cornerRadius(12)
            .foregroundColor(.white)
    }
}

#Preview {
    NavigationView {
        RoutineView()
    }
}
