import Combine
import Foundation

@MainActor
final class TodayInteractor {
    private let appStore: AppStateStore
    private let notificationManager: NotificationManaging
    private let leetCodeSync: LeetCodeSyncInteractor

    init(
        appStore: AppStateStore,
        notificationManager: NotificationManaging,
        leetCodeSync: LeetCodeSyncInteractor
    ) {
        self.appStore = appStore
        self.notificationManager = notificationManager
        self.leetCodeSync = leetCodeSync
    }

    var dataPublisher: Published<AppData>.Publisher {
        appStore.$data
    }

    func currentDayNumber() -> Int {
        appStore.currentDayNumber()
    }

    func toggleProblem(day: Int, problemIndex: Int) {
        appStore.toggleProblem(day: day, problemIndex: problemIndex)
        Task { await checkTopicCompletion(day: day) }
    }

    func toggleHabit(_ habit: String) {
        appStore.toggleHabit(habit)
        Task { await checkAllHabitsCompletion() }
    }

    func advanceToNextDay() {
        appStore.advanceToNextDay()
    }

    func syncSolvedProblems() async -> LeetCodeSyncResult? {
        let username = appStore.data.leetCodeUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !username.isEmpty else { return nil }
        return await leetCodeSync.syncSolvedProblems(
            username: username,
            limit: LeetCodeConstants.manualSubmissionsLimit
        )
    }

    private func checkTopicCompletion(day: Int) async {
        guard let dayData = dsaPlan.first(where: { $0.id == day }) else { return }
        let completedCount = appStore.data.completedProblemsCount(day: day, totalProblems: dayData.problems.count)
        if completedCount == dayData.problems.count {
            let authorized = await notificationManager.checkAuthorizationStatus()
            await notificationManager.sendTopicCompleteCelebration(topic: dayData.topic, authorized: authorized)
        }
    }

    private func checkAllHabitsCompletion() async {
        let habitsToday = appStore.data.todayHabitsCount()
        if habitsToday == AppConstants.totalHabits {
            let authorized = await notificationManager.checkAuthorizationStatus()
            await notificationManager.sendAllHabitsCelebration(authorized: authorized)
        }
    }
}
