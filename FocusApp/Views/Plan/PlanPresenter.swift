import Combine
import Foundation

struct PlanProblemViewModel: Identifiable {
    let id: UUID
    let problem: Problem
    let isCompleted: Bool
    let index: Int
}

struct PlanDayViewModel: Identifiable {
    let id: Int
    let date: String
    let topic: String
    let problems: [PlanProblemViewModel]
    let completedCount: Int

    var isFullyCompleted: Bool {
        completedCount == problems.count
    }
}

@MainActor
final class PlanPresenter: ObservableObject {
    @Published private(set) var days: [PlanDayViewModel] = []
    @Published var isSyncing: Bool = false
    @Published var lastSyncResult: String = ""

    private let interactor: PlanInteractor
    private var cancellables = Set<AnyCancellable>()

    init(interactor: PlanInteractor) {
        self.interactor = interactor
        bind()
    }

    func toggleProblem(day: Int, problemIndex: Int) {
        interactor.toggleProblem(day: day, problemIndex: problemIndex)
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
                self?.days = Self.buildDayViewModels(from: data)
            }
            .store(in: &cancellables)
    }

    private func scheduleSyncMessageClear() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            lastSyncResult = ""
        }
    }

    private static func buildDayViewModels(from data: AppData) -> [PlanDayViewModel] {
        dsaPlan.map { day in
            let completedCount = data.completedProblemsCount(day: day.id, totalProblems: day.problems.count)
            let problems = day.problems.enumerated().map { index, problem in
                PlanProblemViewModel(
                    id: problem.id,
                    problem: problem,
                    isCompleted: data.isProblemCompleted(day: day.id, problemIndex: index),
                    index: index
                )
            }
            return PlanDayViewModel(
                id: day.id,
                date: day.date,
                topic: day.topic,
                problems: problems,
                completedCount: completedCount
            )
        }
    }
}
