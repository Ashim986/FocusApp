# FocusApp - Agent Guide

## Project Overview
FocusApp is a native macOS study companion for Data Structures & Algorithms preparation. It tracks a 13-day core plan plus a 2-day priority sprint (25 problems), daily habits, and focus tools. Progress syncs from LeetCode. Bundled solution write-ups live in `FocusApp/Resources/Solutions.json` (103 problems).

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
├── FocusApp.xcodeproj/              # Xcode project (SPM dependency on FocusDesignSystem)
├── FocusApp/                        # Main app source
│   ├── FocusApp.swift               # App entry point, MenuBarExtra, FloatingWidgetController
│   ├── AppContainer.swift           # Dependency injection container
│   ├── FocusApp.entitlements
│   ├── Assets.xcassets/
│   ├── Models/
│   │   ├── AppData.swift            # Data model for progress/habits
│   │   ├── DataStore.swift          # AppStateStore for state management
│   │   ├── DSAPlan.swift            # Study plan (Difficulty: easy/medium/hard)
│   │   ├── NotificationManager.swift
│   │   ├── NotificationSettings.swift
│   │   ├── NotificationSettingsStore.swift
│   │   ├── NotificationScheduler.swift
│   │   ├── LeetCodeService.swift        # LeetCode sync coordinator
│   │   ├── LeetCodeRestClient+*.swift   # REST client extensions (GraphQL, Requests, etc.)
│   │   ├── LeetCodeNetworking.swift
│   │   ├── LeetCodeErrors.swift
│   │   ├── LeetCodeModels.swift
│   │   ├── LeetCodeConstants.swift
│   │   ├── LeetCodeValueType.swift
│   │   ├── LeetCodeProblemFetcher.swift
│   │   ├── LeetCodeSyncInteractor.swift
│   │   ├── LeetCodeSyncScheduler.swift
│   │   ├── LeetCodeSlugExtractor.swift
│   │   ├── LeetCodeSubmissionService.swift
│   │   ├── ProblemManifestStore.swift
│   │   ├── TestCase.swift           # Test case + language enums
│   │   ├── TestCaseAIService.swift  # AI test case generation (complete input + output)
│   │   ├── CodeExecutionService.swift
│   │   ├── ProcessRunner.swift
│   │   ├── ProcessOutputCollector.swift
│   │   ├── ProcessRunState.swift
│   │   ├── LanguageExecutor.swift
│   │   ├── SwiftExecutor.swift
│   │   ├── SwiftExecutor+Logging.swift
│   │   ├── PythonExecutor.swift
│   │   ├── SolutionModels.swift
│   │   ├── SolutionStore.swift
│   │   ├── SolutionAIService.swift  # AI solution providers (Groq, Gemini)
│   │   ├── TopicSolutionModels.swift
│   │   ├── TopicSolutionStore.swift # Lazy-loading topic solutions
│   │   └── AITestCaseStore.swift    # Hidden test case persistence
│   ├── Views/
│   │   ├── Content/                 # Main tabbed interface
│   │   ├── Plan/                    # Full study plan view
│   │   ├── Today/                   # Today's tasks view
│   │   ├── Stats/                   # Progress statistics
│   │   ├── Focus/                   # Focus mode timer overlay
│   │   ├── Settings/                # Settings view
│   │   ├── ToolbarWidget/           # Floating widget
│   │   ├── CodingEnvironment/
│   │   │   ├── CodingEnvironmentPresenter.swift
│   │   │   ├── CodingEnvironmentInteractor.swift
│   │   │   ├── CodingEnvironmentPresenter+ProblemLoading.swift
│   │   │   ├── CodingEnvironmentPresenter+Persistence.swift
│   │   │   ├── CodingEnvironmentProblemModels.swift
│   │   │   ├── Snippets/                   # LeetCode template building
│   │   │   │   ├── LeetCodeTemplateBuilder.swift
│   │   │   │   ├── LeetCodeTemplateBuilder+Swift.swift
│   │   │   │   ├── LeetCodeTemplateBuilder+Python.swift
│   │   │   │   ├── LeetCodeTemplateBuilder+Helpers.swift
│   │   │   │   └── CodingEnvironmentPresenter+SnippetSelection.swift
│   │   │   ├── Execution/                   # Code execution & instrumentation
│   │   │   │   ├── CodingEnvironmentPresenter+Execution.swift
│   │   │   │   ├── CodingEnvironmentPresenter+ExecutionOutput.swift
│   │   │   │   ├── CodingEnvironmentPresenter+ExecutionDiagnostics.swift
│   │   │   │   ├── CodingEnvironmentPresenter+ExecutionTrace.swift
│   │   │   │   ├── CodingEnvironmentPresenter+LeetCodeSubmit.swift
│   │   │   │   ├── AutoInstrumenter.swift       # Trace.step() injection
│   │   │   │   ├── LeetCodeExecutionWrapper.swift
│   │   │   │   ├── LeetCodeExecutionWrapper+Swift.swift
│   │   │   │   ├── LeetCodeExecutionWrapper+SwiftRunner.swift
│   │   │   │   ├── LeetCodeExecutionWrapper+SwiftTrace.swift
│   │   │   │   ├── LeetCodeExecutionWrapper+Python.swift
│   │   │   │   ├── LeetCodeExecutionWrapper+PythonRunner.swift
│   │   │   │   ├── LeetCodeExecutionWrapper+PythonTrace.swift
│   │   │   │   ├── LeetCodeExecutionWrapper+SignatureParsing.swift
│   │   │   │   └── LeetCodeExecutionWrapper+TypeParsing.swift
│   │   │   ├── Views/                       # UI (uses FocusDesignSystem)
│   │   │   │   ├── CodingEnvironmentView.swift
│   │   │   │   ├── CodingEnvironmentView+Header.swift
│   │   │   │   ├── CodingEnvironmentView+Panels.swift
│   │   │   │   ├── CodingEnvironmentView+Sidebar.swift
│   │   │   │   ├── CodingEnvironmentView+SidebarRows.swift
│   │   │   │   ├── CodingEnvironmentView+DetailContent.swift
│   │   │   │   ├── CodingEnvironmentView+ProblemPicker.swift
│   │   │   │   ├── ProblemDetailTab.swift
│   │   │   │   ├── ModernOutputView.swift       # Result/Console/Debug tabs
│   │   │   │   ├── ModernOutputView+Sections.swift
│   │   │   │   ├── ModernTestCaseView.swift
│   │   │   │   ├── SolutionTabView.swift
│   │   │   │   ├── SolutionApproachView.swift
│   │   │   │   ├── SolutionApproachView+TestCases.swift
│   │   │   │   └── TestCaseEditorView.swift
│   │   │   └── DataJourney/                 # Data structure visualization
│   │   │       ├── DataJourneyModels.swift
│   │   │       ├── DataJourneyPointerModels.swift
│   │   │       ├── DataJourneyDiff.swift
│   │   │       ├── DataJourneyView.swift + Layout/Playback/Selection
│   │   │       ├── DataJourneyStructureCanvasView.swift + extensions
│   │   │       ├── DataJourneyTreeGraphView.swift
│   │   │       ├── DataJourneyGraphView.swift
│   │   │       ├── DataJourneyHeapView.swift
│   │   │       ├── DataJourneyTrieGraphView.swift
│   │   │       ├── DataJourneyMatrixGridView.swift
│   │   │       ├── DataJourneyStringSequenceView.swift
│   │   │       ├── DataJourneyComparisonView.swift
│   │   │       ├── DataJourneyVariableTimeline.swift
│   │   │       └── DataJourneyFlowView.swift
│   │   ├── CodeEditorView.swift     # NSTextView wrapper with syntax highlighting
│   │   ├── CodeEditorView+Coordinator*.swift
│   │   ├── CodeEditorLineNumberRulerView.swift
│   │   ├── OutputPanelView.swift
│   │   ├── ConsoleOutputView.swift
│   │   └── DayCard.swift, ProblemRow.swift
│   ├── Helpers/
│   │   ├── Colors.swift             # Legacy color defs (prefer theme.colors.*)
│   │   └── AppStrings.swift         # Localized string helpers
│   ├── Resources/
│   │   ├── Localizable.xcstrings
│   │   ├── problem-manifest.json
│   │   └── Solutions.json
│   └── Shared/
│       ├── SharedDataStore.swift
│       └── SwiftDataStorage.swift
├── Design/                          # Design documentation
│   ├── README.md
│   ├── Design-Spec.md
│   └── FOCUSAPP_FIGMA_URL.md
├── Scripts/
│   ├── swiftlint.sh
│   ├── fetch_problems.swift
│   ├── generate_solution.swift
│   └── partition_solutions.swift
├── AGENTS.md                        # This file
├── CLAUDE.md                        # Detailed dev guide
└── README.md                        # Project readme
```

## Architecture (Summary)
- Clean/VIPER-style separation: View → Presenter → Interactor → AppStateStore → SwiftData.
- Views observe Presenters (`@ObservedObject`).
- Interactors perform business logic and update the store.

## FocusDesignSystem (External SPM Package)
- Repository: `https://github.com/Ashim986/DSFocusFlow` (version >= 1.0.1)
- Provides themeable UI components: `DSCard`, `DSBadge`, `DSButton`, `DSSelect`, `DSSegmentedControl`, `DSProgressRing`, `DSMetricCard`, `DSToast`, etc.
- Theme accessed via `@Environment(\.dsTheme) var theme`
- Use `theme.colors.*` for colors (textPrimary, textSecondary, surface, border, primary, success, danger, warning, accent)
- Use `theme.typography.*` for fonts (subtitle, caption, mono)
- **Important**: `@Environment(\.dsTheme) var theme` must be `internal` (not `private`) when view has extensions in separate files
- Documentation: `/Users/ashimdahal/Documents/FocusDesignSystem/README.md` and `Docs/DEVELOPMENT_GUIDE.md`

## Floating Widget
- Window controller: `FocusApp/FocusApp.swift` (FloatingWidgetController)
- UI: `FocusApp/Views/ToolbarWidget/ToolbarWidgetView.swift`
- Always-on-top, resizable NSPanel (default 350x560).

## LeetCode Sync
- Client + sync: `FocusApp/Models/LeetCodeService.swift` (supporting GraphQL/networking types in `LeetCode*.swift`)
- Store: `FocusApp/Models/DataStore.swift`
- Plan data: `FocusApp/Models/DSAPlan.swift` (Difficulty: easy/medium/hard)

## Hidden Test Cases & Submission
- AI providers (Groq/Gemini) generate complete test cases (input + expected output) — no reference solution execution
- Protocol: `TestCaseAIProviding` in `Models/TestCaseAIService.swift`
- Cached in `AITestCaseStore` at `~/Library/Application Support/FocusApp/ai-testcases.json`
- Hidden test gate runs before LeetCode submission, progress shown with color-coded ✓/✗
- `AutoInstrumenter` in `Execution/AutoInstrumenter.swift` injects `Trace.step()` with scope-aware variable capture
- **`orderMatters` flag**: `SolutionTestCase` has `orderMatters: Bool` (default `true`). AI sets `false` for "return in any order" problems. `outputMatches()` uses sorted JSON array comparison only when `orderMatters: false`.

## Console Output (print() Statements)
- User `print()` → stdout → `ProcessRunner` pipe → `parseTraceOutput()` → `cleanOutput` → `compilationOutput` → Console tab
- `parseTraceOutput()` strips `__focus_trace__` lines, keeps all other stdout (including `print()`)
- In test execution mode, output is prefixed per test: `"Test N:\n{cleanOutput}"`
- If no explicit `print()` in user code, Console shows only the wrapper's function return values

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
- Use `theme.colors.*` from FocusDesignSystem for colors (not hardcoded `Color.app*`).
- Keep user-facing copy concise.
- Update `AGENTS.md` and `CLAUDE.md` whenever the app structure changes.

## Testing
- Run unit tests with:
  ```bash
  xcodebuild test -project FocusApp.xcodeproj -scheme FocusApp -destination 'platform=macOS'
  ```
- Tests live in `FocusAppTests/` (grouped by feature).
- Currently 604 tests, 0 failures.
