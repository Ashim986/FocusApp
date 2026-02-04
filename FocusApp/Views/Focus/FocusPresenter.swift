import Combine
import Foundation

@MainActor
final class FocusPresenter: ObservableObject {
    @Published var duration: Int = 180
    @Published var timeRemaining: Int = 0
    @Published var totalTime: Int = 0
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var isCompleted = false
    @Published var hasStarted = false

    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(timeRemaining) / Double(totalTime)
    }

    var timeString: String {
        let hours = timeRemaining / 3600
        let minutes = (timeRemaining % 3600) / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }

    var minutesFocused: Int {
        totalTime / 60
    }

    func startTimer() {
        let clamped = max(duration, 1)
        totalTime = clamped * 60
        timeRemaining = totalTime
        hasStarted = true
        isRunning = true
        isPaused = false
        isCompleted = false
    }

    func handleTick() {
        if isRunning && !isPaused && timeRemaining > 0 {
            timeRemaining -= 1
        } else if timeRemaining == 0 && hasStarted && !isCompleted {
            isCompleted = true
            isRunning = false
        }
    }

    func togglePause() {
        isPaused.toggle()
    }

    func endSession() {
        resetSession()
    }

    func resetSession() {
        timeRemaining = 0
        totalTime = 0
        isRunning = false
        isPaused = false
        isCompleted = false
        hasStarted = false
    }
}
