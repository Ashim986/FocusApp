import Foundation

// MARK: - App-Level Routes

/// Top-level routes for the entire app.
enum AppRoute: Hashable {
    /// Main window with tabbed content
    case main
    /// Floating widget NSPanel (macOS) / WidgetKit (iOS)
    case widget
    /// Native settings scene
    case settings
}

// MARK: - Content Routes

/// Routes within the main content area (tab + coding overlay).
enum ContentRoute: Hashable {
    /// A tab is selected (plan, today, stats)
    case tab(Tab)
    /// The coding environment is open
    case coding(CodingRoute)
}

// MARK: - Coding Environment Routes

/// Routes within the coding environment flow.
enum CodingRoute: Hashable {
    /// Main code editor view
    case editor
}

// MARK: - Coding Sheets

/// Sheets that can be presented within the coding environment.
enum CodingSheet: Identifiable, Hashable {
    case submissionTag
    case debugLogs

    var id: Self { self }
}

// MARK: - Widget Routes

/// Routes within the floating widget flow.
enum WidgetRoute: Hashable {
    case main
    case settings
    case tomorrow
}

// MARK: - Focus Routes

/// Routes within the focus timer flow.
enum FocusRoute: Hashable {
    case idle
    case selectDuration
    case running
    case paused
    case completed
}

// MARK: - iOS Tab Bar Routes

/// Routes for the iOS tab bar coordinator.
enum TabBarRoute: Hashable {
    case tab(Tab)
}

// MARK: - iOS Tab Flow Routes

/// Routes for a tab's internal navigation stack (e.g., Today → CodingDetail).
enum TabFlowRoute: Hashable {
    /// Root view of the tab
    case root
    /// Pushed coding detail for a specific problem
    case codingDetail(problemSlug: String)
}

// MARK: - iOS Settings Routes

/// Routes for the settings flow on iOS.
enum SettingsRoute: Hashable {
    case closed
    case presented
}
