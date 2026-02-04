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

    private let interactor: PlanInteractor
    private var cancellables = Set<AnyCancellable>()

    init(interactor: PlanInteractor) {
        self.interactor = interactor
        bind()
    }

    func toggleProblem(day: Int, problemIndex: Int) {
        interactor.toggleProblem(day: day, problemIndex: problemIndex)
    }

    private func bind() {
        interactor.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.days = Self.buildDayViewModels(from: data)
            }
            .store(in: &cancellables)
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
