import Combine
import Foundation

struct TodayProblemViewModel: Identifiable {
    let id: UUID
    let problem: Problem
    let isCompleted: Bool
    let index: Int
}

struct TodayDayViewModel: Identifiable {
    let id: Int
    let topic: String
    let problems: [TodayProblemViewModel]
    let completedCount: Int
    let totalCount: Int
    let isToday: Bool
}

struct HabitViewModel: Identifiable {
    let id: String
    let title: String
    let icon: String
    let isCompleted: Bool
}

@MainActor
final class TodayPresenter: ObservableObject {
    @Published private(set) var visibleDays: [TodayDayViewModel] = []
    @Published private(set) var habits: [HabitViewModel] = []
    @Published private(set) var habitsCompletedCount: Int = 0
    @Published var isSyncing: Bool = false
    @Published var lastSyncResult: String = ""

    private let interactor: TodayInteractor
    private var cancellables = Set<AnyCancellable>()

    init(interactor: TodayInteractor) {
        self.interactor = interactor
        bind()
    }

    func toggleHabit(_ habit: String) {
        interactor.toggleHabit(habit)
    }

    func toggleProblem(day: Int, problemIndex: Int) {
        interactor.toggleProblem(day: day, problemIndex: problemIndex)
    }

    func advanceToNextDay() {
        interactor.advanceToNextDay()
    }

    func syncNow() {
        guard !isSyncing else { return }
        isSyncing = true
        lastSyncResult = "Syncing..."
        Task {
            let result = await interactor.syncSolvedProblems()
            await MainActor.run {
                if let result {
                    if result.syncedCount > 0 {
                        lastSyncResult = "Synced \(result.syncedCount) new problems"
                    } else if result.totalMatched > 0 {
                        lastSyncResult = "\(result.totalMatched) problems up to date"
                    } else {
                        lastSyncResult = "Sync complete"
                    }
                } else {
                    lastSyncResult = "Set username in Settings"
                }
                isSyncing = false
                scheduleSyncMessageClear()
            }
        }
    }

    private func bind() {
        interactor.dataPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                guard let self else { return }
                visibleDays = Self.buildVisibleDays(
                    from: data,
                    currentDay: interactor.currentDayNumber()
                )
                habits = Self.buildHabits(from: data)
                habitsCompletedCount = data.todayHabitsCount()
            }
            .store(in: &cancellables)
    }

    private func scheduleSyncMessageClear() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            lastSyncResult = ""
        }
    }

    private static func buildVisibleDays(from data: AppData, currentDay: Int) -> [TodayDayViewModel] {
        let normalizedDay = max(1, min(currentDay, dsaPlan.count))
        var days: [TodayDayViewModel] = []

        for day in dsaPlan where day.id <= normalizedDay {
            let isToday = day.id == normalizedDay
            let totalCount = day.problems.count
            let completedCount = data.completedProblemsCount(day: day.id, totalProblems: totalCount)

            let problems = day.problems.enumerated().compactMap { index, problem -> TodayProblemViewModel? in
                let isCompleted = data.isProblemCompleted(day: day.id, problemIndex: index)
                if !isToday && isCompleted {
                    return nil
                }
                return TodayProblemViewModel(
                    id: problem.id,
                    problem: problem,
                    isCompleted: isCompleted,
                    index: index
                )
            }

            if isToday || !problems.isEmpty {
                days.append(
                    TodayDayViewModel(
                        id: day.id,
                        topic: day.topic,
                        problems: problems,
                        completedCount: completedCount,
                        totalCount: totalCount,
                        isToday: isToday
                    )
                )
            }
        }

        return days
    }

    private struct HabitDefinition {
        let id: String
        let title: String
        let icon: String
    }

    private static func buildHabits(from data: AppData) -> [HabitViewModel] {
        let definitions: [HabitDefinition] = [
            HabitDefinition(id: "dsa", title: "DSA Study", icon: "book.fill"),
            HabitDefinition(id: "exercise", title: "Exercise", icon: "figure.run"),
            HabitDefinition(id: "other", title: "Other Study", icon: "graduationcap.fill")
        ]
        return definitions.map { definition in
            HabitViewModel(
                id: definition.id,
                title: definition.title,
                icon: definition.icon,
                isCompleted: data.getHabitStatus(habit: definition.id)
            )
        }
    }
}
