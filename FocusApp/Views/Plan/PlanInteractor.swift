import Combine
import Foundation

@MainActor
final class PlanInteractor {
    private let appStore: AppStateStore
    private let notificationManager: NotificationManager

    init(appStore: AppStateStore, notificationManager: NotificationManager) {
        self.appStore = appStore
        self.notificationManager = notificationManager
    }

    var dataPublisher: Published<AppData>.Publisher {
        appStore.$data
    }

    func toggleProblem(day: Int, problemIndex: Int) {
        appStore.toggleProblem(day: day, problemIndex: problemIndex)
        Task { await checkTopicCompletion(day: day) }
    }

    private func checkTopicCompletion(day: Int) async {
        guard let dayData = dsaPlan.first(where: { $0.id == day }) else { return }
        let completedCount = appStore.data.completedProblemsCount(day: day, totalProblems: dayData.problems.count)
        if completedCount == dayData.problems.count {
            let authorized = await notificationManager.checkAuthorizationStatus()
            await notificationManager.sendTopicCompleteCelebration(topic: dayData.topic, authorized: authorized)
        }
    }
}
