import SwiftUI

/// Manages all navigation state within the coding environment.
///
/// Replaces 5 scattered `@State` booleans in `CodingEnvironmentView` with
/// centralized, observable state. Provides `resetForNewProblem()` to prevent
/// stale-state crashes when switching problems.
@MainActor
final class CodingCoordinator: Coordinating, ObservableObject {
    @Published var activeRoute: CodingRoute = .editor

    /// The sheet currently presented (nil = no sheet).
    @Published var activeSheet: CodingSheet?

    /// Whether the problem picker popover is shown.
    @Published var isProblemPickerShown: Bool = false

    /// Whether the problem sidebar overlay is shown.
    @Published var isProblemSidebarShown: Bool = false

    /// The selected tab in the problem detail panel.
    @Published var detailTab: ProblemDetailTab = .description

    /// Whether the bottom output panel is collapsed.
    @Published var isBottomPanelCollapsed: Bool = false

    let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    func start() {}

    // MARK: - Problem Picker

    func showProblemPicker() { isProblemPickerShown = true }
    func hideProblemPicker() { isProblemPickerShown = false }
    func toggleProblemPicker() { isProblemPickerShown.toggle() }

    // MARK: - Problem Sidebar

    func showProblemSidebar() { isProblemSidebarShown = true }
    func hideProblemSidebar() { isProblemSidebarShown = false }
    func toggleProblemSidebar() { isProblemSidebarShown.toggle() }

    // MARK: - Sheets

    func showSubmissionTag() { activeSheet = .submissionTag }
    func showDebugLogs() { activeSheet = .debugLogs }
    func dismissSheet() { activeSheet = nil }

    // MARK: - Detail Tab

    func selectDetailTab(_ tab: ProblemDetailTab) { detailTab = tab }

    // MARK: - Bottom Panel

    func toggleBottomPanel() { isBottomPanelCollapsed.toggle() }

    // MARK: - State Reset

    /// Resets all transient UI state when a new problem is selected.
    /// Prevents stale-state crashes from persisted `@State` across problem switches.
    func resetForNewProblem() {
        isProblemPickerShown = false
        isProblemSidebarShown = false
        activeSheet = nil
        detailTab = .description
        isBottomPanelCollapsed = false
    }
}
