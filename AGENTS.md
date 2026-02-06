# FocusApp - Agent Guide

## Project Overview
FocusApp is a native macOS study companion for Data Structures & Algorithms preparation. It tracks a 13-day core plan plus a 2-day priority sprint (25 problems), daily habits, and focus tools. Progress syncs from LeetCode.

## Project Structure
```
FocusApp/
├── .claude/                         # Tooling metadata (local)
├── .git/                            # Git metadata
├── DerivedData/                     # Build artifacts (generated)
├── FocusAppTests/                   # Unit tests (grouped by feature)
│   ├── AppState/
│   ├── CodingEnvironment/
│   ├── Content/
│   ├── Focus/
│   ├── LeetCode/
│   ├── Plan/
│   ├── Settings/
│   ├── Stats/
│   ├── Today/
│   ├── ToolbarWidget/
│   └── Support/
├── FocusApp.xcodeproj/              # Xcode project
├── FocusApp/                        # Main app source
│   ├── FocusApp.swift               # App entry point, MenuBarExtra, FloatingWidgetController
│   ├── AppContainer.swift           # Dependency injection container
│   ├── FocusApp.entitlements
│   ├── Assets.xcassets/
│   ├── Models/
│   │   ├── AppData.swift            # Data model for progress/habits
│   │   ├── DataStore.swift          # AppStateStore for state management
│   │   ├── DSAPlan.swift            # Study plan definition (priority sprint + core plan)
│   │   ├── NotificationManager.swift    # Notification entry point
│   │   ├── NotificationSettings.swift
│   │   ├── NotificationSettingsStore.swift
│   │   ├── NotificationScheduler.swift
│   │   ├── LeetCodeService.swift    # LeetCode client + sync coordinator
│   │   ├── LeetCodeNetworking.swift
│   │   ├── LeetCodeErrors.swift
│   │   ├── LeetCodeModels.swift
│   │   ├── LeetCodeConstants.swift
│   │   ├── LeetCodeSyncScheduler.swift
│   │   ├── LeetCodeSlugExtractor.swift
│   │   ├── TestCase.swift           # Test case + language enums
│   │   ├── CodeExecutionService.swift
│   │   ├── ProcessRunner.swift
│   │   ├── LanguageExecutor.swift
│   │   ├── SwiftExecutor.swift
│   │   └── PythonExecutor.swift
│   ├── Views/
│   │   ├── Content/
│   │   │   ├── ContentView.swift        # Main tabbed interface
│   │   │   ├── ContentPresenter.swift
│   │   │   ├── ContentInteractor.swift
│   │   │   └── ContentView+Preview.swift
│   │   ├── Plan/
│   │   │   ├── PlanView.swift           # Full study plan view
│   │   │   ├── PlanPresenter.swift
│   │   │   └── PlanInteractor.swift
│   │   ├── Today/
│   │   │   ├── TodayView.swift          # Today's tasks view
│   │   │   ├── TodayPresenter.swift
│   │   │   ├── TodayInteractor.swift
│   │   │   ├── TodayView+Sections.swift
│   │   │   ├── TodayView+FocusCTA.swift
│   │   │   └── TodayView+Preview.swift
│   │   ├── Stats/
│   │   │   ├── StatsView.swift          # Progress statistics
│   │   │   ├── StatsPresenter.swift
│   │   │   ├── StatsInteractor.swift
│   │   │   ├── StatsView+Sections.swift
│   │   │   ├── StatsView+FocusReminder.swift
│   │   │   └── StatsView+Preview.swift
│   │   ├── Focus/
│   │   │   ├── FocusOverlay.swift       # Focus mode timer overlay
│   │   │   ├── FocusPresenter.swift
│   │   │   ├── FocusInteractor.swift
│   │   │   ├── FocusOverlay+Sections.swift
│   │   │   ├── FocusOverlay+TimerView.swift
│   │   │   └── FocusOverlay+CompletionView.swift
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift       # Settings view
│   │   │   ├── SettingsPresenter.swift
│   │   │   ├── SettingsInteractor.swift
│   │   │   ├── SettingsView+Bindings.swift
│   │   │   ├── SettingsView+Validation.swift
│   │   │   └── SettingsView+Preview.swift
│   │   ├── ToolbarWidget/
│   │   │   ├── ToolbarWidgetView.swift  # Floating widget
│   │   │   ├── ToolbarWidgetPresenter.swift
│   │   │   ├── ToolbarWidgetInteractor.swift
│   │   │   ├── ToolbarWidgetView+Header.swift
│   │   │   ├── ToolbarWidgetView+Settings.swift
│   │   │   ├── ToolbarWidgetView+Summary.swift
│   │   │   ├── ToolbarWidgetView+Problems.swift
│   │   │   ├── ToolbarWidgetView+Habits.swift
│   │   │   ├── ToolbarWidgetView+Tomorrow.swift
│   │   │   ├── ToolbarWidgetView+Preview.swift
│   │   │   ├── WidgetCard.swift
│   │   │   ├── ProblemRowWidget.swift
│   │   │   ├── HabitToggle.swift
│   │   │   ├── CarryoverProblemRow.swift
│   │   │   └── TomorrowProblemRow.swift
│   │   ├── CodingEnvironment/
│   │   │   ├── CodingEnvironmentView.swift
│   │   │   ├── CodingEnvironmentPresenter.swift
│   │   │   ├── CodingEnvironmentInteractor.swift
│   │   │   ├── CodingEnvironmentPresenter+Execution.swift
│   │   │   ├── CodingEnvironmentPresenter+ProblemLoading.swift
│   │   │   ├── CodingEnvironmentPresenter+Persistence.swift
│   │   │   ├── CodingEnvironmentPresenter+Snippets.swift
│   │   │   ├── CodingEnvironmentProblemModels.swift
│   │   │   ├── CodingEnvironmentView+Header.swift
│   │   │   ├── CodingEnvironmentView+Panels.swift
│   │   │   ├── CodingEnvironmentView+ProblemPicker.swift
│   │   │   ├── CodingEnvironmentView+Sidebar.swift
│   │   │   ├── CodingEnvironmentView+DetailContent.swift
│   │   │   ├── DataJourneyModels.swift
│   │   │   ├── DataJourneyPointerModels.swift
│   │   │   ├── DataJourneyTraceBubble.swift
│   │   │   ├── DataJourneyTraceValueView.swift
│   │   │   ├── DataJourneySequenceBubbleRow.swift
│   │   │   ├── DataJourneySequenceBubbleRow+Layout.swift
│   │   │   ├── DataJourneyStructureCanvasView.swift
│   │   │   ├── DataJourneyStructureCanvasView+Structure.swift
│   │   │   ├── DataJourneyStructureCanvasView+Pointers.swift
│   │   │   ├── DataJourneyStructureCanvasView+CombinedList.swift
│   │   │   ├── DataJourneyStructureCanvasView+Labels.swift
│   │   │   ├── DataJourneyDictionaryStructureRow.swift
│   │   │   ├── DataJourneyTreeGraphView.swift
│   │   │   ├── DataJourneyGraphView.swift
│   │   │   ├── DataJourneyView.swift
│   │   │   ├── DataJourneyView+Layout.swift
│   │   │   ├── DataJourneyView+Playback.swift
│   │   │   ├── DataJourneyView+Selection.swift
│   │   │   ├── ModernTestCaseView.swift
│   │   │   ├── ModernOutputView.swift
│   │   │   ├── ModernOutputView+Sections.swift
│   │   │   └── TestCaseEditorView.swift
│   │   ├── CodeEditorView.swift     # NSTextView wrapper with syntax highlighting
│   │   ├── CodeEditorView+Coordinator.swift
│   │   ├── CodeEditorView+CoordinatorInput.swift
│   │   ├── CodeEditorView+CoordinatorHighlighting.swift
│   │   ├── CodeEditorView+CoordinatorIndentation.swift
│   │   ├── CodeEditorView+CoordinatorBrackets.swift
│   │   ├── OutputPanelView.swift    # Console output with line numbers
│   │   ├── OutputPanelView+Sections.swift
│   │   ├── ConsoleOutputView.swift
│   │   ├── ProblemSelectionView.swift   # Problem selection (legacy)
│   │   ├── DayCard.swift            # Day card component
│   │   └── ProblemRow.swift         # Problem row component
│   ├── Helpers/
│   │   └── Colors.swift             # Color definitions
│   └── Shared/
│       └── SharedDataStore.swift    # FileAppStorage, PlanCalendar, AppConstants
├── AGENTS.md                        # This file
├── CLAUDE.md                        # Detailed dev guide
└── README.md                        # Project readme
```

## Architecture (Summary)
- Clean/VIPER-style separation: View → Presenter → Interactor → AppStateStore → FileAppStorage.
- Views observe Presenters (`@ObservedObject`).
- Interactors perform business logic and update the store.

## Floating Widget
- Window controller: `FocusApp/FocusApp.swift` (FloatingWidgetController)
- UI: `FocusApp/Views/ToolbarWidget/ToolbarWidgetView.swift`
- Always-on-top, resizable NSPanel (default 350x560).

## LeetCode Sync
- Client + sync: `FocusApp/Models/LeetCodeService.swift` (supporting GraphQL/networking types in `LeetCode*.swift`)
- Store: `FocusApp/Models/DataStore.swift`
- Plan data: `FocusApp/Models/DSAPlan.swift`

## Data Storage
- SwiftData persistent store (default location under Application Support).
- Stores progress, habits, day offset, username, and saved solutions.

## How to Run
```bash
open FocusApp.xcodeproj
# Cmd+R in Xcode
```
Or CLI build:
```bash
xcodebuild -project FocusApp.xcodeproj -scheme FocusApp -configuration Debug build
```

## Conventions
- Keep layout changes localized to view files.
- Prefer native APIs over new dependencies.
- Keep user-facing copy concise.
- Update `AGENTS.md` and `CLAUDE.md` whenever the app structure changes.

## Testing
- Run unit tests with:
  ```bash
  xcodebuild test -project FocusApp.xcodeproj -scheme FocusApp -destination 'platform=macOS'
  ```
- Tests live in `FocusAppTests/` (grouped by feature).
