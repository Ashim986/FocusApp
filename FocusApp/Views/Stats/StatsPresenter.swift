import Combine
import Foundation

struct TopicBreakdownViewModel: Identifiable {
    let id: Int
    let topic: String
    let completed: Int
    let total: Int

    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var isComplete: Bool {
        completed == total
    }
}

struct StatsViewModel {
    let solvedProblems: Int
    let totalProblems: Int
    let completedTopics: Int
    let totalTopics: Int
    let habitsToday: Int
    let daysLeft: Int
    let topicBreakdown: [TopicBreakdownViewModel]
}

@MainActor
final class StatsPresenter: ObservableObject {
    @Published private(set) var viewModel: StatsViewModel

    private let interactor: StatsInteractor
    private var cancellables = Set<AnyCancellable>()

    init(interactor: StatsInteractor) {
        self.interactor = interactor
        self.viewModel = Self.buildViewModel(from: interactor.dataSnapshot())
        bind()
    }

    private func bind() {
        interactor.dataPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.viewModel = Self.buildViewModel(from: data)
            }
            .store(in: &cancellables)
    }

    private static func buildViewModel(from data: AppData) -> StatsViewModel {
        let totalProblems = dsaPlan.reduce(0) { $0 + $1.problems.count }
        let solvedProblems = data.totalCompletedProblems()
        let completedTopics = data.completedTopicsCount()
        let totalTopics = dsaPlan.count
        let habitsToday = data.todayHabitsCount()
        let daysLeft = Self.daysLeftUntilEnd(from: data.planStartDate)
        let breakdown = dsaPlan.map { day in
            let completed = data.completedProblemsCount(day: day.id, totalProblems: day.problems.count)
            return TopicBreakdownViewModel(
                id: day.id,
                topic: day.topic,
                completed: completed,
                total: day.problems.count
            )
        }

        return StatsViewModel(
            solvedProblems: solvedProblems,
            totalProblems: totalProblems,
            completedTopics: completedTopics,
            totalTopics: totalTopics,
            habitsToday: habitsToday,
            daysLeft: daysLeft,
            topicBreakdown: breakdown
        )
    }

    private static func daysLeftUntilEnd(from startDate: Date) -> Int {
        let calendar = Calendar.current
        let normalizedStart = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: Date())
        let daysElapsed = calendar.dateComponents([.day], from: normalizedStart, to: today).day ?? 0
        let clampedElapsed = max(0, daysElapsed)
        let totalDays = dsaPlan.count
        let remaining = totalDays - (clampedElapsed + 1)
        return max(0, remaining)
    }
}
