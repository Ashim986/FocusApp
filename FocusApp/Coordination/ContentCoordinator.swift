import SwiftUI

/// Manages the main content area navigation: tab switching and coding environment overlay.
///
/// Replaces `ContentRouter`, the `@State showCodeEnvironment` boolean, and the
/// callback-threading pattern (`onSelectProblem` passed through multiple layers).
///
/// Platform-agnostic: macOS uses ZStack overlay, iOS uses NavigationStack push,
/// iPadOS uses NavigationSplitView detail column. The coordinator logic is the same.
@MainActor
final class ContentCoordinator: ParentCoordinating, ObservableObject {
    @Published var activeRoute: ContentRoute = .tab(.today)
    @Published var navigationPath = NavigationPath()
    var childCoordinators: [any Coordinating] = []

    let container: AppContainer
    private(set) lazy var codingCoordinator = CodingCoordinator(container: container)

    /// The currently selected tab (computed from activeRoute).
    var selectedTab: Tab {
        get {
            if case .tab(let tab) = activeRoute { return tab }
            return lastTab
        }
        set {
            lastTab = newValue
            activeRoute = .tab(newValue)
        }
    }

    /// Whether the coding environment overlay is presented.
    var isCodingPresented: Bool {
        if case .coding = activeRoute { return true }
        return false
    }

    /// For iPadOS `NavigationSplitView` column management (future).
    var columnVisibility: NavigationSplitViewVisibility {
        isCodingPresented ? .doubleColumn : .automatic
    }

    /// Remembers which tab was active before entering the coding environment.
    private var lastTab: Tab = .today

    init(container: AppContainer) {
        self.container = container
        addChild(codingCoordinator)
    }

    func start() {
        codingCoordinator.start()
    }

    // MARK: - Navigation Actions

    func selectTab(_ tab: Tab) {
        lastTab = tab
        activeRoute = .tab(tab)
    }

    /// Opens the coding environment for a specific problem.
    ///
    /// This replaces the multi-layer callback threading:
    /// - Old: ContentView.openCodingEnvironment → router.selectProblem → presenter.selectProblem
    /// - New: coordinator.openCodingEnvironment (single call)
    func openCodingEnvironment(problem: Problem, day: Int, index: Int) {
        if case .tab(let tab) = activeRoute { lastTab = tab }
        container.codingEnvironmentPresenter.selectProblem(problem, at: index, day: day)
        codingCoordinator.resetForNewProblem()
        codingCoordinator.activeRoute = .editor
        activeRoute = .coding(.editor)
    }

    /// Opens the coding environment without selecting a specific problem.
    /// The presenter's `ensureProblemSelection()` auto-selects the first unsolved problem.
    func openCodingEnvironmentGeneric() {
        if case .tab(let tab) = activeRoute { lastTab = tab }
        codingCoordinator.resetForNewProblem()
        codingCoordinator.activeRoute = .editor
        activeRoute = .coding(.editor)
    }

    /// Closes the coding environment and returns to the previously selected tab.
    func closeCodingEnvironment() {
        codingCoordinator.resetForNewProblem()
        activeRoute = .tab(lastTab)
    }
}
