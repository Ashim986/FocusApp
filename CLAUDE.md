# FocusApp - Development Guide

## Project Overview

FocusApp is a native macOS study companion app for Data Structures & Algorithms preparation. It helps track a 13-day study plan with 65 LeetCode problems, daily habits, and provides focus tools. The app automatically syncs with your LeetCode account to track solved problems.

## Project Structure

```
FocusApp/
├── FocusApp.xcodeproj/              # Xcode project
├── FocusAppTests/                   # Unit tests (non-view logic)
│   ├── Interactors/
│   ├── Models/
│   ├── Presenters/
│   ├── Routers/
│   ├── Services/
│   ├── Stores/
│   └── Support/
├── FocusApp/                        # Main app source
│   ├── FocusApp.swift               # App entry point, MenuBarExtra, FloatingWidgetController
│   ├── AppContainer.swift           # Dependency injection container
│   ├── FocusApp.entitlements
│   ├── Assets.xcassets/
│   ├── Models/
│   │   ├── AppData.swift            # Data model for progress/habits
│   │   ├── DataStore.swift          # AppStateStore for state management
│   │   ├── DSAPlan.swift            # 13-day study plan definition
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
│   │   ├── TestCase.swift           # Test case model, ProgrammingLanguage enum, ExecutionResult
│   │   ├── CodeExecutionService.swift   # Main code execution coordinator
│   │   ├── ProcessRunner.swift      # Low-level process execution with timeout
│   │   ├── LanguageExecutor.swift   # Protocol and config for language executors
│   │   ├── SwiftExecutor.swift      # Swift compilation and execution
│   │   ├── PythonExecutor.swift     # Python interpreter execution
│   │   ├── SolutionModels.swift     # Bundled solution data models
│   │   └── SolutionStore.swift      # Solution loader (Solutions.json)
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
│   │   │   ├── CodingEnvironmentView.swift  # Code editor with problem picker and tests
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
│   │   │   ├── SolutionTabView.swift
│   │   │   ├── SolutionApproachView.swift
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
│   │   ├── CodeEditorLineNumberRulerView.swift  # Line numbers with diagnostics
│   │   ├── OutputPanelView.swift    # Console output with line numbers
│   │   ├── OutputPanelView+Sections.swift
│   │   ├── ConsoleOutputView.swift
│   │   ├── ProblemSelectionView.swift   # Problem selection (legacy)
│   │   ├── DayCard.swift            # Day card component
│   │   └── ProblemRow.swift         # Problem row component
│   ├── Helpers/
│   │   ├── Colors.swift             # Color definitions
│   │   └── AppStrings.swift         # Localized string helpers
│   ├── Resources/
│   │   ├── Localizable.xcstrings    # Localization strings catalog
│   │   └── Solutions.json           # Bundled solutions content
│   └── Shared/
│       ├── SharedDataStore.swift    # PlanCalendar, AppConstants, legacy FileAppStorage
│       └── SwiftDataStorage.swift   # SwiftData persistence (AppDataRecord, SwiftDataAppStorage)
├── Scripts/
│   └── swiftlint.sh                 # SwiftLint build phase script
├── DerivedData/                     # Build artifacts (gitignored)
├── .swiftlint.yml                   # SwiftLint configuration
├── SWIFTLINT.md                     # SwiftLint setup guide
├── CLAUDE.md                        # This file
├── AGENTS.md                        # Agent instructions
└── README.md                        # Project readme
```

## Documentation Maintenance

- Update `AGENTS.md` and `CLAUDE.md` whenever the app structure changes.

## Running the App

```bash
# Open in Xcode
open FocusApp.xcodeproj

# Press Cmd+R to run
```

## Running Tests

```bash
# Run all tests via xcodebuild
xcodebuild test -project FocusApp.xcodeproj -scheme FocusApp -destination 'platform=macOS'

# Or use Cmd+U in Xcode
```

Tests cover all Presenters, Interactors, and core business logic. See `FocusAppTests/` for the full test suite.

## Debug Logs

- `DebugLogStore` and entry models live in `FocusApp/Models/LeetCodeNetworking.swift`.
- Logs are emitted for network, sync, and execution (compile/run).
- Debug log UI is embedded in the code editor and available in Settings.

## Code Execution & Sandbox

The app uses `Process` to compile/run code. App Sandbox is disabled for the macOS target to allow execution of compiled binaries. If you re-enable sandboxing, you will need a helper tool or XPC service to run code safely.

## Code Quality & Linting

### SwiftLint Setup

```bash
# Install SwiftLint
brew install swiftlint

# Run linter
swiftlint lint

# Auto-fix correctable issues
swiftlint lint --fix
```

### Coding Guidelines

The project enforces these standards via `.swiftlint.yml`:

| Rule | Threshold | Description |
|------|-----------|-------------|
| Line length | 120 warning, 200 error | Keep lines readable |
| Function body | 50 warning, 100 error | Keep functions focused |
| Type body | 300 warning, 500 error | Split large types |
| Cyclomatic complexity | 15 warning, 25 error | Reduce branching |
| Sorted imports | Required | Alphabetical order |
| Trailing comma | Required | In multi-line collections |
| Force unwrap/cast/try | Warning | Prefer safe alternatives |

### Custom Rules

- **No print statements**: Use proper logging
- **No hardcoded colors**: Use `Colors.swift` definitions
- **Presenter @MainActor**: All Presenters must have `@MainActor`
- **TODO with owner**: Format as `// TODO(username): description`

### Xcode Build Phase

Add SwiftLint as a Run Script build phase:
```bash
if command -v swiftlint &> /dev/null; then
    swiftlint lint --config "${SRCROOT}/.swiftlint.yml"
fi
```

See `SWIFTLINT.md` for detailed setup instructions.

## Architecture

The app uses a **Clean Architecture / VIPER-inspired** pattern with clear separation of concerns:

### Layer Structure

```
┌─────────────────────────────────────────────────────────────┐
│                          View                                │
│   SwiftUI Views that observe @ObservedObject Presenters     │
├─────────────────────────────────────────────────────────────┤
│                       Presenter                              │
│   @MainActor ObservableObject with @Published state          │
│   Transforms data for the view, handles user actions        │
├─────────────────────────────────────────────────────────────┤
│                       Interactor                             │
│   Business logic, data access via AppStateStore             │
├─────────────────────────────────────────────────────────────┤
│                    AppStateStore                             │
│   Central @Published data store with persistence            │
├─────────────────────────────────────────────────────────────┤
│                    SwiftData Store                           │
│   Persistent local storage (Application Support)             │
└─────────────────────────────────────────────────────────────┘
```

### Key Components

| Component | File | Purpose |
|-----------|------|---------|
| `AppContainer` | `AppContainer.swift` | Dependency injection, creates all presenters/interactors |
| `AppStateStore` | `Models/DataStore.swift` | Central reactive data store with `@Published var data` |
| `SwiftDataAppStorage` | `Shared/SwiftDataStorage.swift` | SwiftData-backed persistence |
| `LeetCodeRestClient` | `Models/LeetCodeService.swift` | REST client for LeetCode data |
| `LeetCodeSyncInteractor` | `Models/LeetCodeService.swift` | Sync logic between LeetCode and app |
| `LeetCodeSyncScheduler` | `Models/LeetCodeSyncScheduler.swift` | Hourly + daily LeetCode sync scheduling |
| `LeetCodeNetworking` | `Models/LeetCodeNetworking.swift` | URLSession request + auth headers |
| `ContentRouter` | `Views/Content/ContentView.swift` | View factory for tab navigation |
| `FloatingWidgetController` | `FocusApp.swift` | NSPanel management for floating widget |
| `CodeExecutionService` | `Models/CodeExecutionService.swift` | Coordinates code execution across languages |
| `ProcessRunner` | `Models/ProcessRunner.swift` | Low-level process execution with timeout |
| `SwiftExecutor` | `Models/SwiftExecutor.swift` | Swift compilation and execution |
| `PythonExecutor` | `Models/PythonExecutor.swift` | Python interpreter execution |
| `NotificationScheduler` | `Models/NotificationScheduler.swift` | Scheduling + permissions for reminders |
| `AppStrings` | `Helpers/AppStrings.swift` | Localized string helpers |
| `CodeEditorLineNumberRulerView` | `Views/CodeEditorLineNumberRulerView.swift` | Line numbers with diagnostic markers |

### Presenter/Interactor Pattern

Each view has a corresponding Presenter and Interactor:

```swift
// Interactor - Business logic
@MainActor
final class ToolbarWidgetInteractor {
    private let appStore: AppStateStore
    private let leetCodeSync: LeetCodeSyncInteractor

    func toggleHabit(_ habit: String) {
        appStore.toggleHabit(habit)
    }
}

// Presenter - View state
@MainActor
final class ToolbarWidgetPresenter: ObservableObject {
    @Published private(set) var data: AppData
    @Published var isSyncing: Bool = false

    private let interactor: ToolbarWidgetInteractor

    func syncNow() {
        Task { await interactor.syncSolvedProblems(...) }
    }
}

// View - UI
struct ToolbarWidgetView: View {
    @ObservedObject var presenter: ToolbarWidgetPresenter

    var body: some View { ... }
}
```

## Key Features

- **LeetCode-Driven Progress**: Problem completion is synced from LeetCode (no manual checkboxes)
- **LeetCode Auto-Sync**: Automatically syncs solved problems from your LeetCode account on app launch
- **Username Settings**: Change LeetCode username via in-app settings with validation
- **Advance Early**: Complete all problems to unlock next day's set early
- **Floating Widget**: Always-on-top NSPanel (350x560px) showing progress, problems, and habits
- **Tomorrow's Preview**: Collapsible section showing upcoming problems and carryover from today
- **Auto-Carryover**: Unsolved problems from today automatically appear in tomorrow's section
- **Menu Bar Icon**: Brain icon for quick widget toggle
- **Auto-launch**: Widget appears automatically on app start
- **Focus Mode**: Full-screen timer overlay for distraction-free studying
- **Progress Tracking**: Track completed problems and daily habits
- **Notifications**: Periodic reminders to stay on track
- **Code Editor**: Built-in code editor with syntax highlighting for Swift and Python
- **Editor UX**: Auto bracket completion, indentation/outdent, and closing-bracket alignment
- **Code Execution**: Run Swift and Python code directly in the app with console output
- **Localization**: Multi-language support via `Localizable.xcstrings` and `AppStrings` helper

## Floating Widget

The floating widget (350x560px) is an always-on-top, draggable NSPanel window.

### Features
- **Header**: Title, sync button, settings button
- **Settings Panel**: Collapsible panel to change LeetCode username with validation
- **Progress Section**: Overall progress ring, current day/topic, habits count
- **Problem List**: Today's problems with status indicators and LeetCode links
- **Habits**: Toggle buttons for DSA, Exercise, Other
- **Tomorrow Section**: Collapsible preview of tomorrow's topic and problems
- **Advance Button**: "Start Day X" appears when all problems are solved

### Interactions
| Action | Result |
|--------|--------|
| Click problem name | Open LeetCode in browser |
| Click sync icon | Sync with LeetCode to update solved status |
| Click gear icon | Open/close settings panel |
| Drag widget | Reposition on screen |
| Click "Tomorrow" | Expand/collapse tomorrow's preview |
| Click "Start Day X" | Advance to next day's problems (when all solved) |

### Settings Panel

Click the gear icon to open settings:

**Username Configuration**
- Text field to enter your LeetCode username
- "Save & Sync" button validates and saves
- Press Enter to save quickly

**Username Validation**
- App verifies username exists on LeetCode before saving
- Shows loading spinner while checking
- Visual feedback:
  - Green border + "Valid" = Username found, saved
  - Red border + "User not found" = Invalid username, not saved
- Validation resets when you start typing again

### LeetCode-Driven Workflow

Problem checkboxes are **read-only** and driven entirely by LeetCode sync:

1. **Solve on LeetCode**: Open problem link, solve it on leetcode.com
2. **Sync**: Click sync icon to fetch your latest submissions
3. **Auto-update**: Checkmarks appear for problems you've solved
4. **Advance**: When all problems are solved, "Start Day X" button appears
5. **Next Day**: Click to advance and get the next day's problems early

### Tomorrow's Preview & Carryover

The widget includes a collapsible "Tomorrow" section at the bottom:

**Carryover Problems (Orange)**
- Unsolved problems from today automatically appear here
- Highlighted in orange to indicate urgency
- Can be marked complete (counts toward today's progress)
- Click problem name to open in LeetCode

**Tomorrow's Problems (Muted)**
- Preview of upcoming day's topic and problems
- Shown with dashed circles (not checkable until that day)
- Click problem name to preview on LeetCode
- Helps with planning ahead

**Visual Indicators**
- `(X carryover)` badge shows count of unsolved problems
- Orange styling for carryover items
- Blue styling for tomorrow's topic header
- Muted colors for tomorrow's problems

## LeetCode Sync

The app syncs directly with LeetCode's GraphQL API to mark problems you've solved.

### How It Works
1. On app launch, fetches your accepted submissions from LeetCode GraphQL API
2. Matches problem slugs (e.g., "reverse-linked-list") with study plan URLs
3. Automatically marks matching problems as solved locally
4. Shows sync status: "Synced X new problems" or "X problems up to date"

### Sync Methods
| Method | How |
|--------|-----|
| Auto (on launch) | Happens when main window appears |
| Widget button | Click sync icon in widget header |
| Menu bar | Brain icon → "Toggle Floating Widget" |

### Configuration
- **Username**: Configurable via in-app settings (click gear icon in widget header)
- **Default Username**: `ashim986`
- **API**: Direct GraphQL to `https://leetcode.com/graphql`

### Changing Username

**Via App (Recommended)**
1. Click gear icon in widget header
2. Enter your LeetCode username
3. Click "Save & Sync" or press Enter
4. App validates username exists before saving
5. If valid, saves and syncs automatically

**Via Code (Alternative)**
Edit default in `FocusApp/Models/AppData.swift`:
```swift
self.leetCodeUsername = "your-leetcode-username"
```

## Data Storage

Progress is stored in a SwiftData persistent store (default location under Application Support).

### Stored Fields
| Field | Purpose |
|-------|---------|
| `progress` | Tracks which problems are solved (day-index: true/false) |
| `habits` | Daily habit completion by date |
| `dayOffset` | Days advanced ahead of schedule (early completion) |
| `leetCodeUsername` | LeetCode username for API sync |
| `savedSolutions` | Saved code per problem+language (keyed by `slug|langSlug`) |

## Key Files to Modify

| File | Purpose |
|------|---------|
| `Models/DSAPlan.swift` | Study plan topics, problems, URLs |
| `Models/LeetCodeService.swift` | LeetCode GraphQL queries and sync logic |
| `Models/AppData.swift` | Default username, data structure |
| `Views/ToolbarWidget/ToolbarWidgetView.swift` | Widget UI, presenters, tomorrow's preview |
| `FocusApp.swift` | FloatingWidgetController, app entry point |
| `AppContainer.swift` | Dependency injection configuration |

### Code Execution Architecture

The code execution system uses a modular architecture for scalability:

```
┌─────────────────────────────────────────────────────────────┐
│                  CodeExecutionService                        │
│   Main coordinator - routes to appropriate executor          │
├─────────────────────────────────────────────────────────────┤
│              LanguageExecutor Protocol                       │
│   Defines execute(code:input:) -> ExecutionResult           │
├──────────────────────┬──────────────────────────────────────┤
│    SwiftExecutor     │         PythonExecutor               │
│  Compiles & runs     │      Runs via interpreter            │
├──────────────────────┴──────────────────────────────────────┤
│                     ProcessRunner                            │
│   Low-level process execution with timeout & output handling │
└─────────────────────────────────────────────────────────────┘
```

| Component | File | Purpose |
|-----------|------|---------|
| `CodeExecuting` | `CodeExecutionService.swift` | Protocol for code execution |
| `CodeExecutionService` | `CodeExecutionService.swift` | Routes execution to appropriate executor |
| `LanguageExecutor` | `LanguageExecutor.swift` | Protocol each language implements |
| `ExecutionConfig` | `LanguageExecutor.swift` | Timeout and temp directory config |
| `ProcessRunner` | `ProcessRunner.swift` | Runs system processes with timeout |
| `SwiftExecutor` | `SwiftExecutor.swift` | Compiles Swift with `swiftc`, then runs |
| `PythonExecutor` | `PythonExecutor.swift` | Runs Python via `python3` interpreter |
| `ExecutionResult` | `TestCase.swift` | Result struct with output, error, exitCode |

### View Components in ToolbarWidget/ToolbarWidgetView.swift

| Component | Purpose |
|-----------|---------|
| `ToolbarWidgetInteractor` | Business logic for widget |
| `ToolbarWidgetPresenter` | Observable state for widget |
| `ToolbarWidgetView` | Main widget container with all sections |
| `WidgetCard` | Card container component |
| `ProblemRowWidget` | Today's problem row with status indicator |
| `HabitToggle` | Habit button (DSA, Exercise, Other) |
| `CarryoverProblemRow` | Unsolved problem from today (orange styling) |
| `TomorrowProblemRow` | Tomorrow's problem preview (muted styling) |

## Common Code Tasks

### Toggle widget
```swift
FloatingWidgetController.shared.toggle(presenter: container.toolbarWidgetPresenter)
```

### Sync with LeetCode (via presenter)
```swift
presenter.syncNow()
```

### Sync with LeetCode (via interactor)
```swift
let result = await leetCodeSync.syncSolvedProblems(username: username, limit: 20)
// result.syncedCount - newly synced problems
// result.totalMatched - total matched problems
```

### Validate username
```swift
let isValid = await leetCodeSync.validateUsername("username")
```

### Advance to next day (when all problems solved)
```swift
appStore.advanceToNextDay()
```

### Get current day (with offset)
```swift
let day = appStore.currentDayNumber()  // Includes any advance offset
```

### Toggle habit
```swift
appStore.toggleHabit("dsa")  // or "exercise", "other"
```

### Check problem completion
```swift
let isDone = appStore.isProblemCompleted(day: 1, problemIndex: 0)
```

### Apply solved slugs from LeetCode
```swift
let result = appStore.applySolvedSlugs(solvedSlugs)
// result.syncedCount - newly marked as solved
// result.totalMatched - total matching problems
```

### Get tomorrow's data
```swift
let tomorrowDay = min(currentDayNumber + 1, 13)
let tomorrowTopic = dsaPlan.first(where: { $0.id == tomorrowDay })?.topic
let tomorrowProblems = dsaPlan.first(where: { $0.id == tomorrowDay })?.problems
```

### Get carryover (unsolved) problems
```swift
let carryover = todaysProblems.enumerated().compactMap { index, problem in
    data.isProblemCompleted(day: currentDayNumber, problemIndex: index) ? nil : (index, problem)
}
```

### Execute code
```swift
let service = CodeExecutionService()
let result = await service.execute(code: code, language: .swift, input: "")
// result.output - stdout
// result.error - stderr
// result.exitCode - process exit code
// result.timedOut - true if execution timed out
// result.isSuccess - true if exitCode == 0 && !timedOut && error.isEmpty
```

### Create custom executor configuration
```swift
let config = ExecutionConfig(timeout: 30, tempDirectory: customDir)
let service = CodeExecutionService(config: config)
```

### Use localized strings
```swift
// Simple string
let title = AppStrings.localized("coding.sidebar_title")

// With format arguments
let pending = AppStrings.format("coding.sidebar_pending_left", count)
```

### Add a new language executor
```swift
// 1. Create new executor conforming to LanguageExecutor
final class JavaScriptExecutor: LanguageExecutor {
    let language: ProgrammingLanguage = .javascript  // Add to enum first
    private let processRunner: ProcessRunning
    private let config: ExecutionConfig

    func execute(code: String, input: String) async -> ExecutionResult {
        // Implementation using processRunner
    }
}

// 2. Add to CodeExecutionService convenience init or use ExecutorFactory
```

## Coding Environment

The app includes a built-in coding environment accessible from Focus Mode.

### Features
- **Problem Picker**: Dropdown to select any problem from the study plan
- **Code Editor**: Syntax highlighting for Swift and Python
- **Language Toggle**: Switch between Swift and Python
- **Test Cases**: View expected input/output for problems
- **Code Execution**: Run code and see console output
- **Solution Persistence**: Code is saved per problem+language and restored on revisit
- **Signature Prefill**: LeetCode code snippets are inserted when available (used for function signatures)

### Syntax Highlighting
The code editor highlights:
- **Keywords** (purple): `func`, `class`, `if`, `for`, `def`, `import`, etc.
- **Types** (cyan): `Int`, `String`, `Bool`, `Array`, `List`, etc.
- **Functions** (golden): Function names in declarations and calls
- **Strings** (green): String literals
- **Numbers** (amber): Numeric literals
- **Comments** (gray): `//` and `#` comments

### Code Execution Flow
1. User writes code in editor
2. Clicks "Run" button (uses first testcase input if present)
3. `CodingEnvironmentPresenter` calls `CodeExecutionService.execute()`
4. Service routes to appropriate executor (Swift or Python)
5. Executor uses `ProcessRunner` to run the code
6. Result displayed in output panel with syntax coloring

## Localization

The app supports multiple languages via the standard Apple localization system.

### Architecture

| Component | Purpose |
|-----------|---------|
| `Localizable.xcstrings` | String catalog containing all localizable strings |
| `AppStrings` | Helper enum for accessing localized strings |

### Usage

```swift
// Simple localized string
AppStrings.localized("coding.sidebar_title")

// Formatted string with arguments
AppStrings.format("coding.sidebar_pending_left", pendingCount)
```

### Adding New Strings

1. Add the key to `FocusApp/Resources/Localizable.xcstrings`
2. Use `AppStrings.localized()` or `AppStrings.format()` in code
3. Xcode will auto-detect new strings for translation

### String Key Conventions

- Use dot notation: `section.identifier`
- Examples: `coding.sidebar_title`, `coding.status_solved`, `coding.section_today`

## Known Limitations

1. **macOS Only**: Native macOS app, won't run on iOS
2. **Sandbox Disabled**: Required for home directory file access
3. **Public Profile**: Your LeetCode profile must be public for sync to work
4. **GraphQL Rate Limits**: LeetCode may rate limit frequent requests
5. **Code Execution**: Requires `swiftc` and `python3` in system PATH

## Build & Distribution

### Development
1. Open `FocusApp.xcodeproj` in Xcode
2. Press `Cmd+R` to build and run

### Release Build
1. Product > Archive
2. Export as "Copy App"
3. No code signing required for personal use

### Requirements
- macOS 14.0+
- Xcode 15.0+
- Swift 5.0
- Internet connection (for LeetCode sync)
