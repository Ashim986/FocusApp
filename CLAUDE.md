# FocusApp - Development Guide

## Project Overview

FocusApp is a native macOS + iOS study companion app for Data Structures & Algorithms preparation. It helps track a 13-day core plan plus a 2-day priority sprint (25 problems), daily habits, and provides focus tools. The app automatically syncs with your LeetCode account to track solved problems. On iOS, code execution uses the LeetCode `interpret_solution` API. A WidgetKit extension provides Home Screen widgets for progress tracking.

Bundled solution write-ups live in `FocusApp/Resources/Solutions.json` (103 problems spanning the core plan and sprint list).

## Project Structure

```
FocusApp/
├── FocusApp.xcodeproj/              # Xcode project (SPM dependency on FocusDesignSystem)
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
├── FocusWidget/                     # WidgetKit extension (iOS)
│   ├── FocusWidgetBundle.swift      # @main WidgetBundle
│   ├── ProgressWidget.swift         # Small/Medium progress widget
│   ├── TodayWidget.swift            # Large today's problems widget
│   ├── WidgetData.swift             # Shared data model + reader (also in iOS target)
│   └── FocusWidget.entitlements     # App Group entitlement
├── FocusApp/                        # Main app source
│   ├── FocusApp.swift               # macOS app entry point, MenuBarExtra, FloatingWidgetController
│   ├── FocusAppiOS.swift            # iOS app entry point
│   ├── AppContainer.swift           # Dependency injection container
│   ├── FocusApp.entitlements        # macOS entitlements
│   ├── FocusAppiOS.entitlements     # iOS entitlements (App Group for widget)
│   ├── Assets.xcassets/
│   ├── Models/
│   │   ├── AppData.swift            # FocusData alias + app-specific helpers
│   │   ├── DataStore.swift          # AppStateStore for state management
│   │   ├── DSAPlan.swift            # Study plan definition (priority sprint + core plan)
│   │   ├── NotificationManager.swift    # Notification entry point
│   │   ├── NotificationSettings.swift
│   │   ├── NotificationSettingsStore.swift
│   │   ├── NotificationScheduler.swift
│   │   ├── LeetCodeService.swift        # FocusData alias for networking service
│   │   ├── LeetCodeRestClient+GraphQL.swift
│   │   ├── LeetCodeRestClient+ProblemContent.swift
│   │   ├── LeetCodeRestClient+Requests.swift
│   │   ├── LeetCodeRestClient+SolvedSlugs.swift
│   │   ├── LeetCodeRestClient+Validation.swift
│   │   ├── LeetCodeNetworking.swift     # FocusData alias for request/logging types
│   │   ├── LeetCodeErrors.swift         # FocusData error aliases
│   │   ├── LeetCodeModels.swift         # FocusData model aliases
│   │   ├── LeetCodeConstants.swift      # FocusData constants aliases
│   │   ├── LeetCodeValueType.swift
│   │   ├── LeetCodeProblemFetcher.swift     # GraphQL fetcher for problem manifest
│   │   ├── LeetCodeSyncInteractor.swift
│   │   ├── LeetCodeSyncScheduler.swift
│   │   ├── LeetCodeSlugExtractor.swift
│   │   ├── LeetCodeSubmissionService.swift  # LeetCode code submission + result polling
│   │   ├── ProblemManifestStore.swift       # Manifest-backed topic planning
│   │   ├── TestCase.swift           # Test case model, ProgrammingLanguage enum, ExecutionResult
│   │   ├── TestCaseAIService.swift  # AI test case generation protocol + providers
│   │   ├── CodeExecutionService.swift   # Main code execution coordinator
│   │   ├── ProcessRunner.swift      # Low-level process execution with timeout
│   │   ├── ProcessOutputCollector.swift
│   │   ├── ProcessRunState.swift
│   │   ├── LanguageExecutor.swift   # Protocol and config for language executors
│   │   ├── SwiftExecutor.swift      # Swift compilation and execution
│   │   ├── SwiftExecutor+Logging.swift
│   │   ├── PythonExecutor.swift     # Python interpreter execution
│   │   ├── SolutionModels.swift     # Bundled solution data models
│   │   ├── SolutionStore.swift      # Solution loader (Solutions.json)
│   │   ├── SolutionAIService.swift  # AI solution providers (Groq, Gemini)
│   │   ├── TopicSolutionModels.swift    # Topic-partitioned solution models
│   │   ├── TopicSolutionStore.swift     # Lazy-loading topic solution store
│   │   ├── AITestCaseStore.swift        # Hidden test case persistence (JSON)
│   │   ├── LeetCodeExecutionService.swift   # iOS code execution via LeetCode API
│   │   └── WidgetDataWriter.swift       # Writes widget data to App Group container
│   ├── Views/
│   │   ├── Shared/                      # Cross-platform shared types
│   │   │   ├── Tab.swift                # Tab enum (extracted from ContentView)
│   │   │   ├── CodeEditorDiagnostic.swift
│   │   │   ├── DifficultyBadgeHelper.swift
│   │   │   └── DesignSystemRoot.swift
│   │   ├── Content/
│   │   │   ├── ContentPresenter.swift
│   │   │   ├── ContentInteractor.swift
│   │   │   ├── macOS/
│   │   │   │   ├── ContentView.swift    # Main tabbed interface
│   │   │   │   └── ContentView+Preview.swift
│   │   │   └── iOS/
│   │   │       └── iOSRootView.swift    # RootViewiOS
│   │   ├── Plan/
│   │   │   ├── PlanPresenter.swift
│   │   │   ├── PlanInteractor.swift
│   │   │   ├── macOS/  → PlanView.swift
│   │   │   └── iOS/    → iOSPlanView.swift (PlanViewiOS)
│   │   ├── Today/
│   │   │   ├── TodayPresenter.swift
│   │   │   ├── TodayInteractor.swift
│   │   │   ├── macOS/  → TodayView.swift (+ extensions)
│   │   │   └── iOS/    → iOSTodayView.swift (TodayViewiOS)
│   │   ├── Stats/
│   │   │   ├── StatsPresenter.swift, StatsInteractor.swift
│   │   │   ├── macOS/  → StatsView.swift (+ extensions)
│   │   │   └── iOS/    → iOSStatsView.swift (StatsViewiOS)
│   │   ├── Focus/
│   │   │   ├── FocusPresenter.swift, FocusInteractor.swift
│   │   │   ├── macOS/  → FocusOverlay.swift (+ extensions)
│   │   │   └── iOS/    → iOSFocusView.swift (FocusViewiOS), FloatingMiniTimer.swift
│   │   ├── Settings/
│   │   │   ├── SettingsPresenter.swift, SettingsInteractor.swift
│   │   │   ├── macOS/  → SettingsView.swift (+ extensions)
│   │   │   └── iOS/    → iOSSettingsView.swift (SettingsViewiOS)
│   │   ├── ToolbarWidget/
│   │   │   ├── ToolbarWidgetPresenter.swift, ToolbarWidgetInteractor.swift
│   │   │   └── macOS/  → ToolbarWidgetView.swift (+ 12 view files)
│   │   ├── CodingEnvironment/
│   │   │   ├── CodingEnvironmentPresenter.swift (+ extensions, shared)
│   │   │   ├── CodingEnvironmentInteractor.swift (shared)
│   │   │   ├── Snippets/                       # LeetCode template building
│   │   │   ├── Execution/                       # Code execution, submission & instrumentation
│   │   │   │   ├── CodingEnvironmentPresenter+Execution.swift
│   │   │   │   ├── CodingEnvironmentPresenter+LeetCodeSubmit.swift
│   │   │   │   ├── AutoInstrumenter.swift
│   │   │   │   ├── LeetCodeExecutionWrapper.swift (+ Swift/Python extensions)
│   │   │   │   └── ...
│   │   │   ├── macOS/                           # macOS view files
│   │   │   │   ├── CodingEnvironmentView.swift (+ extensions)
│   │   │   │   ├── ModernOutputView.swift (+ sections)
│   │   │   │   ├── SolutionTabView.swift, SolutionApproachView.swift
│   │   │   │   └── TestCaseEditorView.swift
│   │   │   ├── iOS/                             # iOS view files
│   │   │   │   ├── iOSCodingView.swift          # CodingViewiOS (adaptive iPhone/iPad)
│   │   │   │   ├── iOSOutputView.swift          # OutputViewiOS (tabbed output panel)
│   │   │   │   ├── iOSSolutionView.swift        # SolutionViewiOS (approaches + complexity)
│   │   │   │   └── CodeMirrorEditorView.swift   # WKWebView code editor with diagnostics
│   │   │   └── DataJourney/                     # Data structure visualization
│   │   │       ├── DataJourneyModels.swift
│   │   │       ├── DataJourneyPointerModels.swift
│   │   │       ├── DataJourneyDiff.swift
│   │   │       ├── DataJourneyTraceBubble.swift
│   │   │       ├── DataJourneyTraceValueView.swift
│   │   │       ├── DataJourneySequenceBubbleRow.swift
│   │   │       ├── DataJourneySequenceBubbleRow+Layout.swift
│   │   │       ├── DataJourneyStructureCanvasView.swift
│   │   │       ├── DataJourneyStructureCanvasView+Structure.swift
│   │   │       ├── DataJourneyStructureCanvasView+Pointers.swift
│   │   │       ├── DataJourneyStructureCanvasView+CombinedList.swift
│   │   │       ├── DataJourneyStructureCanvasView+Labels.swift
│   │   │       ├── DataJourneyDictionaryStructureRow.swift
│   │   │       ├── DataJourneyTreeGraphView.swift
│   │   │       ├── DataJourneyGraphView.swift
│   │   │       ├── DataJourneyHeapView.swift
│   │   │       ├── DataJourneyTrieGraphView.swift
│   │   │       ├── DataJourneyMatrixGridView.swift
│   │   │       ├── DataJourneyStringSequenceView.swift
│   │   │       ├── DataJourneyComparisonView.swift
│   │   │       ├── DataJourneyVariableTimeline.swift
│   │   │       ├── DataJourneyFlowView.swift
│   │   │       ├── DataJourneyView.swift
│   │   │       ├── DataJourneyView+Layout.swift
│   │   │       ├── DataJourneyView+Playback.swift
│   │   │       └── DataJourneyView+Selection.swift
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
│   │   ├── Colors.swift             # Color definitions (legacy, prefer theme.colors.*)
│   │   └── AppStrings.swift         # Localized string helpers
│   ├── Resources/
│   │   ├── Localizable.xcstrings    # Localization strings catalog
│   │   ├── problem-manifest.json    # LeetCode problem manifest
│   │   └── Solutions.json           # Bundled solutions content
│   └── Shared/
│       ├── SharedDataStore.swift    # PlanCalendar, AppConstants, storage aliases
│       └── SwiftDataStorage.swift   # SwiftData storage aliases
├── Packages/
│   ├── FocusNetworking/
│   │   ├── Package.swift
│   │   ├── Sources/FocusNetworking/ # LeetCode API client, submission, request executor, debug logs, shared AppData model
│   │   ├── Sources/FocusNetworking/Storage/ # AppStorage, FileAppStorage, InMemoryAppStorage, SwiftDataAppStorage
│   │   └── Tests/FocusNetworkingTests/
│   └── FocusShared/
│       ├── Package.swift
│       ├── Sources/FocusDomain/
│       ├── Sources/FocusData/
│       │   ├── AppData.swift                     # Compatibility aliases to FocusNetworking
│       │   ├── Storage/AppStorage.swift          # Compatibility aliases to FocusNetworking
│       │   ├── Storage/SwiftDataAppStorage.swift # Compatibility aliases to FocusNetworking
│       │   └── Network/FocusNetworkingExports.swift # Public networking exports for app-facing imports
│       └── Tests/
├── Design/                          # Design documentation
│   ├── README.md
│   ├── Design-Spec.md
│   ├── FOCUSAPP_FIGMA_URL.md
│   └── Exports/EXPORT_CHECKLIST.md
├── Scripts/
│   ├── swiftlint.sh                 # SwiftLint build phase script
│   ├── fetch_problems.swift         # Manifest fetcher (GraphQL)
│   ├── generate_solution.swift      # Solution template generator
│   └── partition_solutions.swift    # Splits Solutions.json into topic files
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

# macOS: Select "FocusApp" scheme, press Cmd+R
# iOS: Select "FocusApp-iOS" scheme, pick a simulator, press Cmd+R
```

### Build Targets

| Target | Scheme | Platform |
|--------|--------|----------|
| FocusApp | FocusApp | macOS 14.0+ |
| FocusApp-iOS | FocusApp-iOS | iOS 26+ |
| FocusWidgetExtension | (built with iOS) | iOS 26+ (WidgetKit) |

## Running Tests

```bash
# macOS tests
xcodebuild test -project FocusApp.xcodeproj -scheme FocusApp -destination 'platform=macOS'

# iOS build verification
xcodebuild build -project FocusApp.xcodeproj -scheme FocusApp-iOS -destination 'platform=iOS Simulator,name=iPhone 16'

# Or use Cmd+U in Xcode
```

Tests cover all Presenters, Interactors, and core business logic. See `FocusAppTests/` for the full test suite.

## Debug Logs

- `DebugLogStore` and entry models are implemented in `Packages/FocusNetworking/Sources/FocusNetworking/LeetCodeNetworking.swift`.
- App model files under `FocusApp/Models/LeetCode*.swift` are compatibility aliases to `FocusData`.
- Logs are emitted for network, sync, and execution (compile/run).
- Debug log UI is embedded in the code editor and available in Settings.

## Data Journey Visualization

Current coverage:
- Single linked list
- Doubly linked list
- Array of lists (list-of-lists)
- Binary tree (level-order structure)
- Arrays
- Dictionaries (flat key/value row)
- Graph (adjacency list)
- Pointer motion (step-to-step)
- Output sequence links for combined lists
- Combined list structure view with gap indices and pointer routing

Partial / gaps:
- Sets (treated as arrays/objects)
- Tuples (treated as generic objects/strings)
- Graph variants (directed/weighted/edge list)
- Deeply nested dictionaries/arrays (basic rendering only)
- Multiple pointers to the same node (overlay can be noisy)
- Trees with parent pointers/custom node shapes
- Circular list display beyond cycle arrow
- Queue/stack/heap abstractions
- Large inputs (trace steps capped and values truncated)

High-risk edge cases:
- Aliasing/shared nodes across lists or outputs
- High-degree graphs (edge clutter)
- Very large inputs (truncation and step caps)

## Code Execution & Sandbox

### macOS

The macOS target uses `Process` to compile/run code locally. App Sandbox is disabled to allow execution of compiled binaries. If you re-enable sandboxing, you will need a helper tool or XPC service to run code safely.

### iOS

The iOS target cannot use `Process`. Instead, `LeetCodeExecutionService` sends code to the LeetCode `interpret_solution` API:

1. `POST /problems/{slug}/interpret_solution/` — submits code with test input
2. `GET /submissions/detail/{id}/check/` — polls for execution result
3. Returns `ExecutionResult` with stdout, stderr, and status

**Key details:**
- 3 retries with exponential backoff (1s, 2s, 4s) for network failures
- 20-second timeout per request
- `wrappedCodeForExecution()` returns raw source on iOS (no local harness wrapping) since LeetCode API has its own execution harness
- Conforms to the same `CodeExecuting` protocol as `CodeExecutionService`
- Wired in `AppContainer.swift` via `#if os(iOS)` guard

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
- **No hardcoded colors**: Use `theme.colors.*` from FocusDesignSystem (legacy `Colors.swift` still exists)
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
| `SwiftDataAppStorage` | `Packages/FocusNetworking/Sources/FocusNetworking/Storage/SwiftDataAppStorage.swift` | SwiftData-backed persistence |
| `LeetCodeRestClient` | `Packages/FocusNetworking/Sources/FocusNetworking/LeetCodeService.swift` | REST client for LeetCode data |
| `LeetCodeSyncInteractor` | `Models/LeetCodeSyncInteractor.swift` | Sync logic between LeetCode and app |
| `LeetCodeSyncScheduler` | `Models/LeetCodeSyncScheduler.swift` | Hourly + daily LeetCode sync scheduling |
| `LeetCodeNetworking` | `Packages/FocusNetworking/Sources/FocusNetworking/LeetCodeNetworking.swift` | URLSession request + auth headers + logging |
| `ContentRouter` | `Views/Content/macOS/ContentView.swift` | View factory for tab navigation (macOS) |
| `FloatingWidgetController` | `FocusApp.swift` | NSPanel management for floating widget (macOS) |
| `CodeExecutionService` | `Models/CodeExecutionService.swift` | Coordinates code execution across languages (macOS) |
| `LeetCodeExecutionService` | `Models/LeetCodeExecutionService.swift` | Code execution via LeetCode `interpret_solution` API (iOS) |
| `ProcessRunner` | `Models/ProcessRunner.swift` | Low-level process execution with timeout (macOS) |
| `SwiftExecutor` | `Models/SwiftExecutor.swift` | Swift compilation and execution (macOS) |
| `PythonExecutor` | `Models/PythonExecutor.swift` | Python interpreter execution (macOS) |
| `NotificationScheduler` | `Models/NotificationScheduler.swift` | Scheduling + permissions for reminders |
| `AppStrings` | `Helpers/AppStrings.swift` | Localized string helpers |
| `CodeEditorLineNumberRulerView` | `Views/CodeEditorLineNumberRulerView.swift` | Line numbers with diagnostic markers (macOS) |
| `CodeMirrorEditorView` | `Views/CodingEnvironment/iOS/CodeMirrorEditorView.swift` | WKWebView code editor with diagnostics (iOS) |
| `SolutionAIProviding` | `Models/SolutionAIService.swift` | AI provider protocol + Groq/Gemini implementations |
| `TestCaseAIProviding` | `Models/TestCaseAIService.swift` | AI test case generation (complete input + expected output) |
| `LeetCodeSubmissionService` | `Models/LeetCodeSubmissionService.swift` | LeetCode code submission + result polling |
| `AITestCaseStore` | `Models/AITestCaseStore.swift` | Thread-safe hidden test case persistence (JSON) |
| `AutoInstrumenter` | `Execution/AutoInstrumenter.swift` | Trace.step() injection with scope-aware variable capture |
| `LeetCodeExecutionWrapper` | `Execution/LeetCodeExecutionWrapper.swift` | LeetCode-style code wrapping for Swift/Python |
| `TopicSolutionStore` | `Models/TopicSolutionStore.swift` | Lazy-loading topic-partitioned solution store |
| `WidgetDataWriter` | `Models/WidgetDataWriter.swift` | Writes progress data to App Group for WidgetKit (iOS) |

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

### Shared (macOS + iOS)
- **LeetCode-Driven Progress**: Problem completion is synced from LeetCode (no manual checkboxes)
- **LeetCode Auto-Sync**: Automatically syncs solved problems from your LeetCode account on app launch
- **Username Settings**: Change LeetCode username via in-app settings with validation
- **Advance Early**: Complete all problems to unlock next day's set early
- **Focus Mode**: Full-screen timer overlay for distraction-free studying
- **Progress Tracking**: Track completed problems and daily habits
- **Notifications**: Periodic reminders to stay on track
- **Code Editor**: Built-in code editor with syntax highlighting for Swift and Python
- **Code Execution**: Run code and see output (macOS: local process, iOS: LeetCode API)
- **Hidden Test Gate**: AI-generated test cases validated before LeetCode submission
- **LeetCode Submission**: Direct code submission with result polling
- **Localization**: Multi-language support via `Localizable.xcstrings` and `AppStrings` helper

### macOS Only
- **Floating Widget**: Always-on-top NSPanel (350x560px) showing progress, problems, and habits
- **Menu Bar Icon**: Brain icon for quick widget toggle
- **Auto-launch**: Widget appears automatically on app start
- **Tomorrow's Preview**: Collapsible section showing upcoming problems and carryover from today
- **Auto-Carryover**: Unsolved problems from today automatically appear in tomorrow's section
- **NSTextView Editor**: Full-featured code editor with line number ruler and diagnostics
- **Data Journey**: Step-by-step data structure visualization during code execution

### iOS Only
- **CodeMirror Editor**: WKWebView-based code editor with syntax highlighting, line numbers, and error diagnostics
- **Tabbed Output Panel**: Result/Console/Debug tabs matching macOS output panel
- **Solution View**: Multiple approaches with expandable sections, time/space complexity badges
- **Home Screen Widgets**: WidgetKit extension with progress ring (small/medium) and today's problems (large)
- **Adaptive Layout**: iPhone compact layout vs iPad split-pane layout

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
Edit default in `Packages/FocusNetworking/Sources/FocusNetworking/AppData.swift`:
```swift
self.leetCodeUsername = "your-leetcode-username"
```

## Data Storage

Progress is stored in a SwiftData persistent store (default location under Application Support).
- Shared model + storage implementations live in `Packages/FocusNetworking/Sources/FocusNetworking/` and `Packages/FocusNetworking/Sources/FocusNetworking/Storage/`.
- `Packages/FocusShared/Sources/FocusData/` re-exports compatibility aliases for app-facing imports.
- App code also consumes compatibility aliases in `FocusApp/Models/AppData.swift` and `FocusApp/Shared/*.swift`.

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
| `Packages/FocusNetworking/Sources/FocusNetworking/LeetCodeService.swift` | LeetCode GraphQL queries and sync logic |
| `Packages/FocusNetworking/Sources/FocusNetworking/AppData.swift` | Default username, shared app data structure |
| `Views/ToolbarWidget/ToolbarWidgetView.swift` | Widget UI, presenters, tomorrow's preview |
| `FocusApp.swift` | FloatingWidgetController, app entry point |
| `AppContainer.swift` | Dependency injection configuration |

### Code Execution Architecture

The code execution system uses a modular architecture with platform-specific implementations:

```
                    ┌─────────────────────────┐
                    │    CodeExecuting Protocol │
                    │  execute(code:lang:input) │
                    └────────────┬────────────┘
                                 │
                ┌────────────────┴─────────────────┐
                │                                    │
   ┌────────────▼───────────┐      ┌────────────────▼────────────────┐
   │ macOS: CodeExecution   │      │ iOS: LeetCodeExecution          │
   │        Service         │      │      Service                    │
   │ Routes to executors    │      │ LeetCode interpret_solution API │
   ├────────────────────────┤      │ 3 retries, 20s timeout          │
   │ LanguageExecutor       │      └─────────────────────────────────┘
   │ Protocol               │
   ├──────────┬─────────────┤
   │ Swift    │ Python      │
   │ Executor │ Executor    │
   ├──────────┴─────────────┤
   │     ProcessRunner      │
   └────────────────────────┘
```

| Component | File | Platform | Purpose |
|-----------|------|----------|---------|
| `CodeExecuting` | `CodeExecutionService.swift` | Shared | Protocol for code execution |
| `CodeExecutionService` | `CodeExecutionService.swift` | macOS | Routes execution to appropriate executor |
| `LeetCodeExecutionService` | `LeetCodeExecutionService.swift` | iOS | Runs code via LeetCode API |
| `LanguageExecutor` | `LanguageExecutor.swift` | macOS | Protocol each language implements |
| `ExecutionConfig` | `LanguageExecutor.swift` | macOS | Timeout and temp directory config |
| `ProcessRunner` | `ProcessRunner.swift` | macOS | Runs system processes with timeout |
| `SwiftExecutor` | `SwiftExecutor.swift` | macOS | Compiles Swift with `swiftc`, then runs |
| `PythonExecutor` | `PythonExecutor.swift` | macOS | Runs Python via `python3` interpreter |
| `ExecutionResult` | `TestCase.swift` | Shared | Result struct with output, error, exitCode |

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
- **Hidden Tests**: Background AI-generated test cases (up to 50) run before LeetCode submission
- **LeetCode Submission**: Direct code submission to LeetCode with result polling
- **Progress Feedback**: Real-time hidden test progress with pass/fail color coding (green/red)

### Syntax Highlighting
The code editor highlights:
- **Keywords** (purple): `func`, `class`, `if`, `for`, `def`, `import`, etc.
- **Types** (cyan): `Int`, `String`, `Bool`, `Array`, `List`, etc.
- **Functions** (golden): Function names in declarations and calls
- **Strings** (green): String literals
- **Numbers** (amber): Numeric literals
- **Comments** (gray): `//` and `#` comments

### Code Execution Flow

**Run Flow:**
1. User writes code in editor
2. Clicks "Run" button (uses first testcase input if present)
3. `CodingEnvironmentPresenter` calls `CodeExecutionService.execute()`
4. Service routes to appropriate executor (Swift or Python)
5. Executor uses `ProcessRunner` to run the code
6. Result displayed in output panel with syntax coloring

**Submit Flow:**
1. User taps "Submit" button
2. If local test cases exist, they run first
3. Hidden tests run against user code (progress shown in output panel)
4. Green text = all passing, Red text = failures detected
5. If all hidden tests pass, code submits to LeetCode via `LeetCodeSubmissionService`
6. Failed hidden tests are placed in the test panel for debugging

### Console Output & print() Statements

The output panel has 3 tabs: **Result**, **Console**, **Debug**.

**How print() output flows to the Console tab:**

```
User print() → stdout → ProcessRunner (pipe capture)
  → ProcessOutputCollector → ExecutionResult.output
  → parseTraceOutput() strips __focus_trace__ lines, keeps print() in cleanOutput
  → compilationOutput = cleanOutput (runSingle) or consoleLogs (executeTests)
  → ModernOutputView output: param → Console tab → ConsoleOutputView
```

| Execution Mode | Where print() output appears |
|---------------|------------------------------|
| **Run (no tests)** | `compilationOutput = parsed.cleanOutput` — shows all stdout directly |
| **Run with tests** | Each test's output prefixed with `"Test N:\n"` and joined into `compilationOutput` |
| **Hidden test gate** | Progress text replaces `compilationOutput` during run; final summary after |

**Key details:**
- `ProcessRunner` captures ALL stdout via pipe `readabilityHandler`
- `parseTraceOutput()` separates `__focus_trace__` instrumentation lines from regular output
- Everything that is NOT a trace line (including `print()`) goes into `cleanOutput`
- The Console tab displays `compilationOutput` via `ConsoleOutputView` with line numbers and color detection
- If user code has NO `print()` statements, the Console tab shows only the wrapper's function return values
- The LeetCode execution wrapper prints `jsonString(from: output)` as the LAST stdout line — user `print()` appears BEFORE this

## Hidden Test Cases & LeetCode Submission

The coding environment includes a background AI-driven hidden test case system that validates user solutions before submitting to LeetCode.

### Hidden Test Case Generation

When a user selects a problem, `startHiddenTestGeneration()` runs in the background:
1. AI providers (Groq/Gemini) generate up to 50 **complete test cases** (input + expected output) for the selected problem
2. No reference solution execution is needed — the AI generates both inputs and correct expected outputs directly
3. Generated test cases are cached in `AITestCaseStore` at `~/Library/Application Support/FocusApp/ai-testcases.json`
4. A badge in the **Submissions tab** shows the generation state:
   - Amber = generating in progress
   - Green = test cases ready
   - Gray = unavailable (generation failed or not applicable)

### Output Comparison & `orderMatters` Flag

Test output comparison uses `outputMatches()` in `CodingEnvironmentPresenter+ExecutionOutput.swift`:
- **Exact match first**: Always tries direct string comparison
- **Order-insensitive fallback**: Only when `orderMatters: false`, tries sorting both sides as flat JSON arrays
- The `orderMatters` flag is per-test-case on `SolutionTestCase` (defaults to `true` for backward compatibility)
- AI prompt explicitly asks the provider to set `orderMatters: false` for problems that say "return in any order"
- User-created visible test cases (`TestCase`) always use exact matching (no `orderMatters` flag)
- `sortedJSONArray()` helper parses flat JSON arrays and sorts elements for comparison
- Nested arrays/objects are NOT sorted — only flat `[1,2,"a"]` style arrays

**When order matters vs doesn't**:
| Scenario | `orderMatters` | Example |
|----------|---------------|---------|
| Sorted output (merge sort, inorder traversal) | `true` | `[1,2,3]` must match exactly |
| "Return in any order" problems | `false` | `[1,2]` matches `[2,1]` |
| Single values, booleans, strings | `true` | `"true"`, `"42"` — exact match |
| User-created test cases | `true` (always) | User explicitly typed the expected output |

### Hidden Test Gate on Submit

When the user taps Submit, hidden tests act as a gate before LeetCode submission:
- If no local test cases exist: all hidden tests run, only failures appear in the test panel
- If local test cases exist and all pass: hidden tests run before LeetCode submission
- Progress is shown in the output panel as "Hidden test X/Y" with pass/fail counts
- Text color updates in real-time: faint green while all tests pass, light red when failures are detected
- The `hiddenTestsHaveFailures` flag drives the color switch in real-time
- The bottom panel auto-expands when execution starts (via `.onChange(of: presenter.isRunning)`)

### LeetCode Submission

After all hidden tests pass, `submitToLeetCodeDirect()` submits the user's code to LeetCode:
- `LeetCodeSubmissionService` handles the REST API submission and polls for results
- Polling uses the `finished` field (not `state == "SUCCESS"`) for completion detection
- `submitToLeetCodeDirect()` bypasses the old AI gate and is used by the new hidden test flow

### Key Presenter Properties

| Property | Type | Purpose |
|----------|------|---------|
| `hiddenTestCases` | `[SolutionTestCase]` | Cached hidden test cases for current problem |
| `isGeneratingHiddenTests` | `Bool` | Whether background generation is in progress |
| `hiddenTestsHaveFailures` | `Bool` | Real-time failure tracking during hidden test execution |
| `hiddenTestGenerationTask` | `Task<Void, Never>?` | Cancellable background generation task |

### Key Methods

| Method | File | Purpose |
|--------|------|---------|
| `startHiddenTestGeneration()` | `CodingEnvironmentPresenter+LeetCodeSubmit.swift` | Kicks off background AI test case generation on problem select |
| `runHiddenTestGate(executionCode:)` | `CodingEnvironmentPresenter+Execution.swift` | Runs user code against all hidden tests |
| `submitToLeetCodeDirect()` | `CodingEnvironmentPresenter+LeetCodeSubmit.swift` | Submits to LeetCode after hidden tests pass |

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

## FocusDesignSystem (External Package)

The app uses **FocusDesignSystem** (`DSFocusFlow`) as an SPM dependency for consistent, themeable UI components.

- **Repository**: `https://github.com/Ashim986/DSFocusFlow`
- **Version**: `>= 1.0.1` (upToNextMinor)
- **Platforms**: macOS 14.0+, iOS 26

### Package Structure

| Module | Purpose |
|--------|---------|
| `FocusDesignSystemCore` | Tokens: colors, typography, spacing, radii, shadows + theme environment |
| `FocusDesignSystemState` | Reducer protocol + state store |
| `FocusDesignSystemComponents` | Reusable UI components |
| `FocusDesignSystem` | Umbrella re-export of all modules |

### Theme Usage

```swift
import FocusDesignSystem

// In views — access theme via environment
@Environment(\.dsTheme) var theme

// Use theme tokens
theme.colors.textPrimary
theme.colors.textSecondary
theme.colors.surface
theme.colors.surfaceElevated
theme.colors.background
theme.colors.border
theme.colors.primary
theme.colors.success
theme.colors.danger
theme.colors.warning
theme.colors.accent
theme.typography.subtitle
theme.typography.caption
theme.typography.mono
```

### Available Components

| Component | Usage |
|-----------|-------|
| `DSCard` | Card container with style/padding/cornerRadius config |
| `DSButton` | Themed button with primary/secondary/danger styles |
| `DSBadge` | Status badge (success, warning, danger, neutral) |
| `DSTextField` | Themed text input |
| `DSSelect` | Dropdown select with outlined/compact styles |
| `DSSegmentedControl` | Tab-like segmented control |
| `DSProgressRing` | Circular progress indicator |
| `DSHeader` | Section header with title/subtitle |
| `DSMetricCard` | Metric display with trend indicator |
| `DSToast` | Toast notification |
| `DSBubble` | Data visualization bubble |
| `DSArrow`, `DSCurvedArrow` | Arrow primitives for visualizations |
| `DSGraphView` | Graph visualization (adjacency list) |
| `DSTreeGraphView` | Tree visualization |

### Important Integration Notes

- `@Environment(\.dsTheme) var theme` must be `internal` (not `private`) when the view has extensions in separate files
- Same applies to `@Environment(\.openURL) var openURL`
- `Difficulty` enum has 3 cases: `.easy`, `.medium`, `.hard` (used with `DSBadge` styles)
- Colors in new code should use `theme.colors.*` instead of `Color.app*` from `Colors.swift`

## AutoInstrumenter (Trace.step Injection)

The `AutoInstrumenter` in `Execution/AutoInstrumenter.swift` injects `Trace.step()` calls into user code for the Data Journey visualization system.

### Scope-Aware Variable Capture

The instrumenter uses **scope-aware** variable capture to avoid compilation errors:

1. **Function-level declarations**: `extractFunctionLevelDecls()` returns `[VarDecl]` with `(name, line)` pairs
2. **Declaration ordering**: Only variables declared BEFORE each insertion point are captured: `funcLevelDecls.filter { $0.line < lineIndex }`
3. **Loop-local variables**: `extractSwiftLoopVars()` captures binding variables from `for` loop headers only for that specific loop
4. **No cross-scope leaking**: Loop binding variables (e.g., `count` from `for (num, count) in ...`) don't leak into other loops

### Common Pitfalls

- Never capture variables before their declaration line (causes "use of local variable before its declaration")
- Loop binding variables must be scoped to their containing loop only
- Helper structs/methods live in a separate extension to stay under the `type_body_length` SwiftLint limit

## Known Limitations

1. **Sandbox Disabled (macOS)**: Required for home directory file access and local code execution
2. **Public Profile**: Your LeetCode profile must be public for sync to work
3. **GraphQL Rate Limits**: LeetCode may rate limit frequent requests
4. **macOS Code Execution**: Requires `swiftc` and `python3` in system PATH
5. **iOS Code Execution**: Requires internet — code runs via LeetCode `interpret_solution` API (not local)
6. **iOS Data Journey**: Data structure visualization is not available on iOS (macOS only)
7. **iOS Floating Widget**: The always-on-top NSPanel widget is macOS only; iOS uses WidgetKit Home Screen widgets

## Build & Distribution

### Development
1. Open `FocusApp.xcodeproj` in Xcode
2. Select the appropriate scheme (`FocusApp` for macOS, `FocusApp-iOS` for iOS)
3. Press `Cmd+R` to build and run

### Release Build (macOS)
1. Product > Archive
2. Export as "Copy App"
3. No code signing required for personal use

### Requirements
- macOS 14.0+ (macOS target)
- iOS 26+ (iOS target)
- Xcode 16.0+
- Swift 5.0+
- Internet connection (for LeetCode sync)
- `swiftc` and `python3` in system PATH (macOS code execution only)

## iOS Feature-Folder Convention

Platform-specific views use a feature-folder structure:

```
Views/
  FeatureName/
    FeaturePresenter.swift      ← shared
    FeatureInteractor.swift     ← shared
    macOS/
      FeatureView.swift         ← macOS view
    iOS/
      iOSFeatureView.swift      ← iOS view (type: FeatureViewiOS)
```

**Naming convention**: iOS types follow `ViewNameiOS` pattern (e.g., `CodingViewiOS`, `OutputViewiOS`, `TodayViewiOS`). File names use `iOSViewName.swift` prefix since they're in `iOS/` subfolders. All files are in both targets with `#if os()` guards for platform separation.

## WidgetKit Extension (iOS)

The `FocusWidget` target is a WidgetKit extension providing Home Screen widgets.

### Widgets

| Widget | Size | Content |
|--------|------|---------|
| Progress | Small | Progress ring + completed/total count |
| Progress | Medium | Progress ring + problem list (up to 6) + habits dots |
| Today | Large | Day header, progress bar, problem list (up to 10), habits |

### Data Sharing

The main iOS app writes progress data to a shared App Group container (`group.com.dsafocus.focusapp`) as JSON. The widget reads this data via `WidgetDataReader`.

**Data flow:**
1. `AppStateStore.save()` calls `WidgetDataWriter.write()` on iOS
2. `WidgetDataWriter` computes widget data from `AppData` and writes `widget-data.json` to the App Group container
3. `WidgetCenter.shared.reloadAllTimelines()` triggers widget refresh
4. Widget's `TimelineProvider` reads data via `WidgetDataReader.load()`

### Key Files

| File | Target | Purpose |
|------|--------|---------|
| `FocusWidget/WidgetData.swift` | Widget + iOS | Shared data model, constants, reader |
| `FocusWidget/FocusWidgetBundle.swift` | Widget | `@main` WidgetBundle entry point |
| `FocusWidget/ProgressWidget.swift` | Widget | Small/Medium progress widgets |
| `FocusWidget/TodayWidget.swift` | Widget | Large today's problems widget |
| `FocusApp/Models/WidgetDataWriter.swift` | iOS | Writes data to App Group container |
