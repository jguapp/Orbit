import SwiftUI

struct JournalView: View {
    @StateObject private var journalManager = JournalManager()
    @State private var selectedDate = Date()
    @State private var showingEntrySheet = false
    @State private var selectedMood: Mood = .neutral
    @State private var promptResponses: [String: String] = [:]
    @State private var freeformText: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Calendar View
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(color: Color(.systemGray4), radius: 5)
                
                // Today's Entry or Add Entry Button
                if let entry = journalManager.getEntry(for: selectedDate) {
                    JournalEntryCard(entry: entry) {
                        selectedMood = entry.mood
                        promptResponses = entry.dailyPromptResponses
                        freeformText = entry.freeformText
                        showingEntrySheet = true
                    }
                } else {
                    Button(action: {
                        showingEntrySheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Reflection")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemPurple))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reflections")
        .sheet(isPresented: $showingEntrySheet) {
            NavigationView {
                JournalEntryForm(
                    journalManager: journalManager,
                    selectedDate: selectedDate,
                    selectedMood: $selectedMood,
                    promptResponses: $promptResponses,
                    freeformText: $freeformText,
                    showingSheet: $showingEntrySheet
                )
            }
        }
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    let editAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                    .foregroundColor(Color(.label))
                Spacer()
                Text(entry.mood.emoji)
                    .font(.title2)
            }
            
            Divider()
            
            ForEach(entry.dailyPromptResponses.sorted(by: { $0.key < $1.key }), id: \.key) { prompt, response in
                VStack(alignment: .leading, spacing: 5) {
                    Text(prompt)
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                    Text(response)
                        .font(.body)
                        .foregroundColor(Color(.label))
                }
            }
            
            if !entry.freeformText.isEmpty {
                Divider()
                Text(entry.freeformText)
                    .font(.body)
                    .italic()
                    .foregroundColor(Color(.label))
            }
            
            Button(action: editAction) {
                Text("Edit Entry")
                    .font(.caption)
                    .foregroundColor(Color(.systemPurple))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color(.systemGray4), radius: 5)
    }
}

struct JournalEntryForm: View {
    @ObservedObject var journalManager: JournalManager
    let selectedDate: Date
    @Binding var selectedMood: Mood
    @Binding var promptResponses: [String: String]
    @Binding var freeformText: String
    @Binding var showingSheet: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Mood Selection
                VStack(alignment: .leading) {
                    Text("How are you feeling?")
                        .font(.headline)
                        .foregroundColor(Color(.label))
                    
                    HStack(spacing: 20) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            Button(action: { selectedMood = mood }) {
                                VStack {
                                    Text(mood.emoji)
                                        .font(.title)
                                    Text(mood.rawValue)
                                        .font(.caption)
                                }
                            }
                            .foregroundColor(selectedMood == mood ? Color(mood.color) : Color(.systemGray))
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                
                // Daily Prompts
                VStack(alignment: .leading, spacing: 15) {
                    Text("Daily Reflection")
                        .font(.headline)
                        .foregroundColor(Color(.label))
                    
                    ForEach(journalManager.dailyPrompts, id: \.self) { prompt in
                        VStack(alignment: .leading) {
                            Text(prompt)
                                .font(.subheadline)
                                .foregroundColor(Color(.secondaryLabel))
                            
                            TextField("Your response", text: Binding(
                                get: { promptResponses[prompt] ?? "" },
                                set: { promptResponses[prompt] = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                
                // Freeform Entry
                VStack(alignment: .leading) {
                    Text("Additional Thoughts")
                        .font(.headline)
                        .foregroundColor(Color(.label))
                    
                    TextEditor(text: $freeformText)
                        .frame(height: 100)
                        .padding(5)
                        .background(Color(.systemBackground))
                        .cornerRadius(5)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Journal Entry")
        .navigationBarItems(
            leading: Button("Cancel") {
                showingSheet = false
            },
            trailing: Button("Save") {
                let entry = JournalEntry(
                    date: selectedDate,
                    mood: selectedMood,
                    dailyPromptResponses: promptResponses,
                    freeformText: freeformText
                )
                
                if journalManager.getEntry(for: selectedDate) != nil {
                    journalManager.updateEntry(entry)
                } else {
                    journalManager.addEntry(entry)
                }
                
                showingSheet = false
            }
        )
    }
}

#Preview {
    NavigationView {
        JournalView()
    }
}
