import Combine
import Foundation

@MainActor
final class ContentPresenter: ObservableObject {
    @Published var selectedTab: Tab = .today
    @Published private(set) var solvedProblems: Int = 0
    @Published private(set) var totalProblems: Int = 0
    @Published private(set) var progressPercent: Double = 0

    private let interactor: ContentInteractor
    private var cancellables = Set<AnyCancellable>()

    init(interactor: ContentInteractor) {
        self.interactor = interactor
        self.totalProblems = dsaPlan.reduce(0) { $0 + $1.problems.count }
        bind()
    }

    func onAppear() {
        // Sync scheduling is handled centrally.
    }

    private func bind() {
        interactor.dataPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self else { return }
                let solved = data.totalCompletedProblems()
                solvedProblems = solved
                let total = totalProblems
                progressPercent = total > 0 ? Double(solved) / Double(total) : 0
            }
            .store(in: &cancellables)
    }
}
