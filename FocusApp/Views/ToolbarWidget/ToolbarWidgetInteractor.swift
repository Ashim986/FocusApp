import Combine
import Foundation

@MainActor
final class ToolbarWidgetInteractor {
    private let appStore: AppStateStore
    private let leetCodeSync: LeetCodeSyncInteractor

    init(appStore: AppStateStore, leetCodeSync: LeetCodeSyncInteractor) {
        self.appStore = appStore
        self.leetCodeSync = leetCodeSync
    }

    var dataPublisher: Published<AppData>.Publisher {
        appStore.$data
    }

    var currentData: AppData {
        appStore.data
    }

    func currentDayNumber() -> Int {
        appStore.currentDayNumber()
    }

    func todaysTopic() -> String {
        appStore.todaysTopic()
    }

    func toggleHabit(_ habit: String) {
        appStore.toggleHabit(habit)
    }

    func toggleProblem(day: Int, problemIndex: Int) {
        appStore.toggleProblem(day: day, problemIndex: problemIndex)
    }

    func advanceToNextDay() {
        appStore.advanceToNextDay()
    }

    func currentUsername() -> String {
        appStore.data.leetCodeUsername
    }

    func validateAndSaveUsername(_ username: String) async -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let isValid = await leetCodeSync.validateUsername(trimmed)
        guard isValid else { return false }
        appStore.updateLeetCodeUsername(trimmed)
        _ = await leetCodeSync.syncSolvedProblems(username: trimmed, limit: LeetCodeConstants.manualSubmissionsLimit)
        return true
    }

    func syncSolvedProblems(username: String) async -> LeetCodeSyncResult {
        await leetCodeSync.syncSolvedProblems(username: username, limit: LeetCodeConstants.manualSubmissionsLimit)
    }
}
