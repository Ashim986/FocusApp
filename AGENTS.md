# FocusApp - Agent Guide

## Project Overview
FocusApp is a native macOS + iOS study companion for Data Structures & Algorithms preparation. It tracks a 13-day core plan plus a 2-day priority sprint (25 problems), daily habits, and focus tools. Progress syncs from LeetCode. On iOS, code execution uses the LeetCode `interpret_solution` API. A WidgetKit extension provides Home Screen widgets. Bundled solution write-ups live in `FocusApp/Resources/Solutions.json` (103 problems).

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
│   │   ├── DataStore.swift          # AppStateStore (calls WidgetDataWriter on iOS save)
│   │   ├── DSAPlan.swift            # Study plan (Difficulty: easy/medium/hard)
│   │   ├── LeetCodeExecutionService.swift  # iOS code execution via LeetCode API
│   │   ├── WidgetDataWriter.swift   # Writes widget data to App Group (iOS)
│   │   ├── CodeExecutionService.swift  # macOS code execution coordinator
│   │   ├── ProcessRunner.swift      # macOS process execution
│   │   ├── SwiftExecutor.swift      # macOS Swift compilation
│   │   ├── PythonExecutor.swift     # macOS Python interpreter
│   │   ├── LeetCodeSubmissionService.swift
│   │   ├── LeetCodeSyncInteractor.swift
│   │   ├── LeetCodeSyncScheduler.swift
│   │   ├── TestCase.swift           # Test case + language enums
│   │   ├── TestCaseAIService.swift  # AI test case generation
│   │   ├── AITestCaseStore.swift    # Hidden test case persistence
│   │   └── ... (other model files)
│   ├── Views/
│   │   ├── Shared/                  # Cross-platform shared types
│   │   │   ├── Tab.swift, CodeEditorDiagnostic.swift
│   │   │   ├── DifficultyBadgeHelper.swift
│   │   │   └── DesignSystemRoot.swift
│   │   ├── Content/
│   │   │   ├── ContentPresenter.swift, ContentInteractor.swift
│   │   │   ├── macOS/  → ContentView.swift
│   │   │   └── iOS/    → iOSRootView.swift (RootViewiOS)
│   │   ├── Today/
│   │   │   ├── TodayPresenter.swift, TodayInteractor.swift
│   │   │   ├── macOS/  → TodayView.swift (+ extensions)
│   │   │   └── iOS/    → iOSTodayView.swift (TodayViewiOS)
│   │   ├── Plan/
│   │   │   ├── PlanPresenter.swift, PlanInteractor.swift
│   │   │   ├── macOS/  → PlanView.swift
│   │   │   └── iOS/    → iOSPlanView.swift (PlanViewiOS)
│   │   ├── Stats/
│   │   │   ├── StatsPresenter.swift, StatsInteractor.swift
│   │   │   ├── macOS/  → StatsView.swift (+ extensions)
│   │   │   └── iOS/    → iOSStatsView.swift (StatsViewiOS)
│   │   ├── Focus/
│   │   │   ├── FocusPresenter.swift, FocusInteractor.swift
│   │   │   ├── macOS/  → FocusOverlay.swift (+ extensions)
│   │   │   └── iOS/    → iOSFocusView.swift (FocusViewiOS), FloatingMiniTimer
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
│   │   │   ├── Snippets/               # LeetCode template building
│   │   │   ├── Execution/              # Code execution & instrumentation
│   │   │   ├── macOS/                  # macOS views
│   │   │   │   ├── CodingEnvironmentView.swift (+ extensions)
│   │   │   │   ├── ModernOutputView.swift (Result/Console/Debug tabs)
│   │   │   │   ├── SolutionTabView.swift, SolutionApproachView.swift
│   │   │   │   └── TestCaseEditorView.swift
│   │   │   ├── iOS/                    # iOS views
│   │   │   │   ├── iOSCodingView.swift (CodingViewiOS — adaptive iPhone/iPad)
│   │   │   │   ├── iOSOutputView.swift (OutputViewiOS — tabbed output)
│   │   │   │   ├── iOSSolutionView.swift (SolutionViewiOS — approaches + complexity)
│   │   │   │   └── CodeMirrorEditorView.swift (WKWebView editor + diagnostics)
│   │   │   └── DataJourney/            # Data structure visualization (macOS)
│   │   ├── CodeEditorView.swift (+ Coordinator extensions, macOS NSTextView)
│   │   ├── CodeEditorLineNumberRulerView.swift
│   │   ├── OutputPanelView.swift, ConsoleOutputView.swift
│   │   └── DayCard.swift, ProblemRow.swift
│   ├── Helpers/
│   │   ├── Colors.swift             # Legacy color defs (prefer theme.colors.*)
│   │   └── AppStrings.swift         # Localized string helpers
│   ├── Resources/
│   │   ├── Localizable.xcstrings
│   │   ├── problem-manifest.json
│   │   ├── Solutions.json
│   │   └── CodeEditor/             # CodeMirror JS/CSS bundle for iOS
│   │       ├── index.html
│   │       ├── codemirror-bundle.min.js
│   │       └── codemirror.min.css
│   └── Shared/
│       ├── SharedDataStore.swift    # PlanCalendar/AppConstants + storage aliases
│       └── SwiftDataStorage.swift   # SwiftData storage aliases
├── Packages/
│   ├── FocusNetworking/
│   │   ├── Package.swift
│   │   ├── Sources/FocusNetworking/     # LeetCode API client, submission, request executor, debug logs, shared AppData model
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
- Feature-folder structure: each feature has shared Presenter/Interactor at root, with `macOS/` and `iOS/` subfolders for views.
- All files are in both targets with `#if os()` guards for platform separation.
- iOS types follow `ViewNameiOS` naming (e.g., `CodingViewiOS`, `TodayViewiOS`); file names use `iOSViewName.swift`.

## FocusDesignSystem (External SPM Package)
- Repository: `https://github.com/Ashim986/DSFocusFlow` (version >= 1.0.1)
- Provides themeable UI components: `DSCard`, `DSBadge`, `DSButton`, `DSSelect`, `DSSegmentedControl`, `DSProgressRing`, `DSMetricCard`, `DSToast`, etc.
- Theme accessed via `@Environment(\.dsTheme) var theme`
- Use `theme.colors.*` for colors (textPrimary, textSecondary, surface, border, primary, success, danger, warning, accent)
- Use `theme.typography.*` for fonts (subtitle, caption, mono)
- **Important**: `@Environment(\.dsTheme) var theme` must be `internal` (not `private`) when view has extensions in separate files
- Documentation: `/Users/ashimdahal/Documents/FocusDesignSystem/README.md` and `Docs/DEVELOPMENT_GUIDE.md`

## Floating Widget (macOS)
- Window controller: `FocusApp/FocusApp.swift` (FloatingWidgetController)
- UI: `FocusApp/Views/ToolbarWidget/macOS/ToolbarWidgetView.swift`
- Always-on-top, resizable NSPanel (default 350x560).

## WidgetKit Extension (iOS)
- Entry point: `FocusWidget/FocusWidgetBundle.swift`
- Widgets: `ProgressWidget` (small/medium), `TodayWidget` (large)
- Data sharing: App Group `group.com.dsafocus.focusapp` with JSON file
- Writer: `FocusApp/Models/WidgetDataWriter.swift` (called from `AppStateStore.save()`)

## iOS Code Execution
- `LeetCodeExecutionService` in `Models/LeetCodeExecutionService.swift`
- Uses LeetCode `interpret_solution` API with 3 retries and 20s timeout
- `wrappedCodeForExecution()` returns raw source on iOS (no local harness)
- Conforms to `CodeExecuting` protocol, wired in `AppContainer.swift`

## LeetCode Sync
- Core networking + submission + logging: `Packages/FocusNetworking/Sources/FocusNetworking/`
- App-facing aliases (for backwards compatibility): `FocusApp/Models/LeetCode*.swift`
- Store: `FocusApp/Models/DataStore.swift`
- Plan data: `FocusApp/Models/DSAPlan.swift` (Difficulty: easy/medium/hard)

## Data Storage
- App data model + storage implementations + in-memory stub live in `Packages/FocusNetworking/Sources/FocusNetworking/` and `Packages/FocusNetworking/Sources/FocusNetworking/Storage/`.
- `Packages/FocusShared/Sources/FocusData/` is a compatibility alias layer for app-facing imports.
- App compatibility aliases also remain in `FocusApp/Models/AppData.swift` and `FocusApp/Shared/*.swift`.

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
- SwiftData-backed storage implementation is `Packages/FocusNetworking/Sources/FocusNetworking/Storage/SwiftDataAppStorage.swift`.

## How to Run
```bash
open FocusApp.xcodeproj
# macOS: Select "FocusApp" scheme, Cmd+R
# iOS: Select "FocusApp-iOS" scheme, pick a simulator, Cmd+R
```
Or CLI build:
```bash
# macOS
xcodebuild -project FocusApp.xcodeproj -scheme FocusApp -configuration Debug build

# iOS
xcodebuild build -project FocusApp.xcodeproj -scheme FocusApp-iOS -destination 'platform=iOS Simulator,name=iPhone 16'
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
  # macOS tests
  xcodebuild test -project FocusApp.xcodeproj -scheme FocusApp -destination 'platform=macOS'

  # iOS build verification
  xcodebuild build -project FocusApp.xcodeproj -scheme FocusApp-iOS -destination 'platform=iOS Simulator,name=iPhone 16'
  ```
- Tests live in `FocusAppTests/` (grouped by feature).

## Build Targets

| Target | Scheme | Platform |
|--------|--------|----------|
| FocusApp | FocusApp | macOS 14.0+ |
| FocusApp-iOS | FocusApp-iOS | iOS 26+ |
| FocusWidgetExtension | (built with iOS) | iOS 26+ (WidgetKit) |
