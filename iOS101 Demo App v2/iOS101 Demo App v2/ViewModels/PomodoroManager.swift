import Foundation
import UserNotifications

class PomodoroManager: ObservableObject {
    @Published var minutes: Int
    @Published var seconds: Int = 0
    @Published var isActive = false
    @Published var isBreakTime = false
    @Published var showingAlert = false
    @Published var showingTimeEditor = false
    @Published var lastSessionDuration: Int = 0
    @Published var lastSessionDate: Date?
    @Published var currentStreak: Int = 0
    @Published var bestStreak: Int = 0
    private var focusedDates: Set<Date> = []
    
    var timer: Timer?
    var workMinutes: Int
    var breakMinutes: Int
    
    init() {
        // Set default values to 25 and 5
        let savedWorkMinutes = UserDefaults.standard.integer(forKey: "pomodoroLength")
        let savedBreakMinutes = UserDefaults.standard.integer(forKey: "breakLength")
        
        self.workMinutes = savedWorkMinutes == 0 ? 25 : savedWorkMinutes
        self.breakMinutes = savedBreakMinutes == 0 ? 5 : savedBreakMinutes
        
        // Save default values if not set
        if savedWorkMinutes == 0 {
            UserDefaults.standard.set(25, forKey: "pomodoroLength")
        }
        if savedBreakMinutes == 0 {
            UserDefaults.standard.set(5, forKey: "breakLength")
        }
        
        self.minutes = workMinutes
        requestNotificationPermission()
        loadFocusData()
    }
    
    var workMinutesPublished: Int {
        get {
            return UserDefaults.standard.integer(forKey: "pomodoroLength") == 0 ? 25 : UserDefaults.standard.integer(forKey: "pomodoroLength")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "pomodoroLength")
            if !isActive && !isBreakTime {
                minutes = newValue
            }
        }
    }
    
    var breakMinutesPublished: Int {
        get {
            return UserDefaults.standard.integer(forKey: "breakLength") == 0 ? 5 : UserDefaults.standard.integer(forKey: "breakLength")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "breakLength")
            if !isActive && isBreakTime {
                minutes = newValue
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    func start() {
        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func pause() {
        isActive = false
        timer?.invalidate()
    }
    
    func reset() {
        isActive = false
        timer?.invalidate()
        minutes = isBreakTime ? breakMinutes : workMinutes
        seconds = 0
    }
    
    func toggleMode() {
        isBreakTime.toggle()
        minutes = isBreakTime ? breakMinutes : workMinutes
        seconds = 0
        // Automatically start the timer when mode changes
        start()
    }
    
    private func updateTimer() {
        if seconds > 0 {
            seconds -= 1
        } else if minutes > 0 {
            minutes -= 1
            seconds = 59
        } else {
            timer?.invalidate()
            isActive = false
            showingAlert = true
            // Automatically toggle mode and start when timer is up
            toggleMode()
            // Request notification
            requestNotification()
            if !isBreakTime {
                completeSession()
            }
        }
    }
    
    private func requestNotification() {
        let content = UNMutableNotificationContent()
        content.title = isBreakTime ? "Break Time Started" : "Focus Time Started"
        content.body = isBreakTime ? "Time to recharge!" : "Let's focus!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func completeSession() {
        lastSessionDuration = workMinutes
        lastSessionDate = Date()
        focusedDates.insert(Calendar.current.startOfDay(for: Date()))
        updateStreak()
        
        // Save to UserDefaults
        saveFocusData()
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
            if focusedDates.contains(yesterday) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        }
        
        bestStreak = max(bestStreak, currentStreak)
    }
    
    private func saveFocusData() {
        UserDefaults.standard.set(lastSessionDuration, forKey: "lastSessionDuration")
        UserDefaults.standard.set(lastSessionDate, forKey: "lastSessionDate")
        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
        UserDefaults.standard.set(bestStreak, forKey: "bestStreak")
        // Convert dates to array of timestamps
        let dateTimestamps = focusedDates.map { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(dateTimestamps, forKey: "focusedDates")
    }
    
    private func loadFocusData() {
        lastSessionDuration = UserDefaults.standard.integer(forKey: "lastSessionDuration")
        lastSessionDate = UserDefaults.standard.object(forKey: "lastSessionDate") as? Date
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        bestStreak = UserDefaults.standard.integer(forKey: "bestStreak")
        
        // Load focused dates
        if let timestamps = UserDefaults.standard.array(forKey: "focusedDates") as? [Double] {
            focusedDates = Set(timestamps.map { Date(timeIntervalSince1970: $0) })
        }
    }
    
    func isFocused(on date: Date) -> Bool {
        focusedDates.contains(Calendar.current.startOfDay(for: date))
    }
}
