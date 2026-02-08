import SwiftUI

/// Manages the iOS tab bar state and owns per-tab flow coordinators.
///
/// This is the top-level iOS navigation coordinator, replacing the iOS-side
/// responsibilities of `ContentCoordinator`. It follows the coordinator pattern:
///
/// ```
/// TabBarCoordinator (ParentCoordinating)
/// ├── TodayFlowCoordinator
/// ├── PlanFlowCoordinator
/// ├── StatsFlowCoordinator
/// ├── FocusFlowCoordinator
/// ├── CodingFlowCoordinator → CodingCoordinator
/// └── SettingsCoordinator
/// ```
@MainActor
final class TabBarCoordinator: ParentCoordinating, ObservableObject {
    @Published var activeRoute: TabBarRoute = .tab(.today)
    var childCoordinators: [any Coordinating] = []

    let container: AppContainer

    // Per-tab flow coordinators
    let todayFlow: TodayFlowCoordinator
    let planFlow: PlanFlowCoordinator
    let statsFlow: StatsFlowCoordinator
    let focusFlow: FocusFlowCoordinator
    let codingFlow: CodingFlowCoordinator

    // Settings
    let settingsCoordinator: SettingsCoordinator

    /// Currently selected tab (derived from activeRoute).
    var selectedTab: Tab {
        get {
            if case .tab(let tab) = activeRoute { return tab }
            return .today
        }
        set {
            activeRoute = .tab(newValue)
        }
    }

    init(container: AppContainer, focusCoordinator: FocusCoordinator) {
        self.container = container

        self.todayFlow = TodayFlowCoordinator(container: container)
        self.planFlow = PlanFlowCoordinator(container: container)
        self.statsFlow = StatsFlowCoordinator()
        self.focusFlow = FocusFlowCoordinator(focusCoordinator: focusCoordinator)
        self.codingFlow = CodingFlowCoordinator(container: container)
        self.settingsCoordinator = SettingsCoordinator()

        addChild(todayFlow)
        addChild(planFlow)
        addChild(statsFlow)
        addChild(focusFlow)
        addChild(codingFlow)
        addChild(settingsCoordinator)
    }

    func start() {
        todayFlow.start()
        planFlow.start()
        codingFlow.start()
    }

    // MARK: - Navigation Actions

    func showSettings() {
        settingsCoordinator.present()
    }

    func dismissSettings() {
        settingsCoordinator.dismiss()
    }

    /// Switch to focus tab (used by Today's "Start Focus" button).
    func switchToFocus() {
        selectedTab = .focus
    }

    /// Open coding detail from any tab (e.g., Today → problem tap on iPhone).
    func openCodingDetail(problem: Problem, day: Int, index: Int) {
        container.codingEnvironmentPresenter.selectProblem(problem, at: index, day: day)
        selectedTab = .coding
        codingFlow.pushCodingDetail(problemSlug: problem.url)
    }
}
