import Foundation
import SwiftUI
import WidgetKit

class DataStore: ObservableObject {
    @Published var data: AppData
    @Published var isSyncing: Bool = false
    @Published var lastSyncResult: String = ""
    @Published var isValidatingUsername: Bool = false
    @Published var usernameValidationResult: UsernameValidationResult = .none

    enum UsernameValidationResult {
        case none
        case valid
        case invalid
        case error(String)
    }

    private var notificationManager: NotificationManager?

    init() {
        self.data = AppData()
        load()
    }

    func setNotificationManager(_ manager: NotificationManager) {
        self.notificationManager = manager
    }

    func load() {
        self.data = SharedDataStore.loadData()
    }

    /// Sync solved problems from LeetCode
    func syncWithLeetCode(completion: (() -> Void)? = nil) {
        guard !isSyncing else {
            completion?()
            return
        }

        isSyncing = true
        lastSyncResult = "Syncing..."

        let username = data.leetCodeUsername
        LeetCodeService.shared.syncWithDataStore(self, username: username) { [weak self] synced, total in
            guard let self = self else { return }
            self.isSyncing = false

            if synced > 0 {
                self.lastSyncResult = "Synced \(synced) new problems"
            } else if total > 0 {
                self.lastSyncResult = "\(total) problems up to date"
            } else {
                self.lastSyncResult = "Sync complete"
            }

            // Clear the message after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.lastSyncResult = ""
            }

            completion?()
        }
    }

    func save() {
        SharedDataStore.saveData(data)
        refreshWidgets()
    }

    private func refreshWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    // Toggle problem completion
    func toggleProblem(day: Int, problemIndex: Int) {
        let key = "\(day)-\(problemIndex)"
        let wasCompleted = data.progress[key] ?? false
        data.progress[key] = !wasCompleted
        save()

        // Check if topic is now completed
        if !wasCompleted {
            checkTopicCompletion(day: day)
        }
    }

    // Toggle habit
    func toggleHabit(_ habit: String) {
        let today = AppData.todayString()
        if data.habits[today] == nil {
            data.habits[today] = [:]
        }
        let wasCompleted = data.habits[today]?[habit] ?? false
        data.habits[today]?[habit] = !wasCompleted
        save()

        // Check if all habits are now done
        if !wasCompleted {
            checkAllHabitsCompletion()
        }
    }

    // Check if problem is completed
    func isProblemCompleted(day: Int, problemIndex: Int) -> Bool {
        return data.isProblemCompleted(day: day, problemIndex: problemIndex)
    }

    // Check if habit is done today
    func isHabitDone(_ habit: String) -> Bool {
        return data.getHabitStatus(habit: habit)
    }

    // Check if all problems for a day are completed
    private func checkTopicCompletion(day: Int) {
        guard let dayData = dsaPlan.first(where: { $0.id == day }) else { return }

        let completedCount = data.completedProblemsCount(day: day, totalProblems: dayData.problems.count)
        if completedCount == dayData.problems.count {
            notificationManager?.sendTopicCompleteCelebration(topic: dayData.topic)
        }
    }

    // Check if all habits are done for today
    private func checkAllHabitsCompletion() {
        let habitsToday = data.todayHabitsCount()
        if habitsToday == SharedDataStore.totalHabits {
            notificationManager?.sendAllHabitsCelebration()
        }
    }

    // Advance to next day (when all problems are solved early)
    func advanceToNextDay() {
        let currentDay = SharedDataStore.currentDayNumber(offset: data.dayOffset)
        guard currentDay < 13 else { return }  // Already at last day

        data.dayOffset += 1
        save()

        // Trigger sync to update new day's problems
        syncWithLeetCode()
    }

    // Get current day number (with offset)
    func currentDayNumber() -> Int {
        return SharedDataStore.currentDayNumber(offset: data.dayOffset)
    }

    // Update LeetCode username (without validation)
    func updateLeetCodeUsername(_ username: String) {
        data.leetCodeUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        save()
    }

    // Validate and update LeetCode username
    func validateAndUpdateUsername(_ username: String, completion: @escaping (Bool) -> Void) {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            usernameValidationResult = .invalid
            completion(false)
            return
        }

        isValidatingUsername = true
        usernameValidationResult = .none

        LeetCodeService.shared.validateUsername(trimmed) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isValidatingUsername = false

                switch result {
                case .success(true):
                    self.usernameValidationResult = .valid
                    self.data.leetCodeUsername = trimmed
                    self.save()
                    completion(true)
                case .success(false):
                    self.usernameValidationResult = .invalid
                    completion(false)
                case .failure(let error):
                    self.usernameValidationResult = .error(error.localizedDescription)
                    completion(false)
                }

                // Clear result after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.usernameValidationResult = .none
                }
            }
        }
    }

    // Reset validation state
    func resetUsernameValidation() {
        usernameValidationResult = .none
    }

    // Get current LeetCode username
    var leetCodeUsername: String {
        return data.leetCodeUsername
    }
}
