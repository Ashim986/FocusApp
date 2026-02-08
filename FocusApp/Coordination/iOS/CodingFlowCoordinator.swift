import SwiftUI

/// Manages the coding tab navigation on iOS.
///
/// On iPhone (compact): problem list → push coding detail.
/// On iPad (regular): three-panel layout (no push navigation needed).
///
/// Owns its own `CodingCoordinator` for iOS-specific state management,
/// separate from the macOS instance in `ContentCoordinator`.
@MainActor
final class CodingFlowCoordinator: ParentCoordinating, ObservableObject {
    @Published var activeRoute: TabFlowRoute = .root
    var childCoordinators: [any Coordinating] = []

    let container: AppContainer
    let codingCoordinator: CodingCoordinator

    init(container: AppContainer) {
        self.container = container
        self.codingCoordinator = CodingCoordinator(container: container)
        addChild(codingCoordinator)
    }

    func start() {
        codingCoordinator.start()
    }

    /// Whether the compact (iPhone) coding detail is shown.
    var isDetailShown: Bool {
        if case .codingDetail = activeRoute { return true }
        return false
    }

    /// Push to coding detail (iPhone compact layout).
    func pushCodingDetail(problemSlug: String) {
        codingCoordinator.resetForNewProblem()
        activeRoute = .codingDetail(problemSlug: problemSlug)
    }

    /// Pop back to problem list (iPhone compact layout).
    func popToList() {
        activeRoute = .root
    }

    /// Open a specific problem in the coding environment.
    ///
    /// Sets the problem on the presenter, resets coding state,
    /// and pushes the coding detail view (iPhone) or selects the problem (iPad).
    func openProblem(problem: Problem, day: Int, index: Int) {
        container.codingEnvironmentPresenter.selectProblem(problem, at: index, day: day)
        codingCoordinator.resetForNewProblem()
        codingCoordinator.activeRoute = .editor
        activeRoute = .codingDetail(problemSlug: problem.url)
    }
}
