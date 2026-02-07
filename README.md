# FocusApp

FocusApp is a native macOS study companion for Data Structures & Algorithms preparation. It tracks a 13-day core plan plus a 2-day priority sprint (25 problems), daily habits, focus tools, and a built-in coding environment. The app syncs solved problems from LeetCode to keep progress accurate.

## Features
- LeetCode-driven progress sync (REST with GraphQL fallback)
- Automatic refresh on username change, hourly, and at day start
- Split-view coding workspace with problem list, details, and output panel
- Swift + Python editors with test case execution and submissions tracking
- Problem detail tabs: Description, Editorial, Solution, Submissions, Debug
- Debug logs for network, sync, and execution (Settings + editor)
- Floating always-on-top widget
- Daily habits and progress tracking
- Focus timer indicator in the editor header
- Tomorrow preview and auto-carryover for unsolved problems
- Data journey visualization (lists, list groups, arrays, dictionaries, trees, graphs) with pointer tracking

## Requirements
- macOS 14.0+
- Xcode 15.0+
- Swift 5.0+
- Internet connection (for LeetCode sync)

## Getting Started
1. Open the project in Xcode:
   ```bash
   open FocusApp.xcodeproj
   ```
2. Press `Cmd+R` to build and run.

## Usage
- Set your LeetCode username in Settings.
- Progress syncs automatically in the background.
- Use the code workspace to view problems, run test cases, and save solutions.
- Toggle the floating widget with `Cmd+Shift+W`.

## Configuration
- Default username can be edited in `FocusApp/Models/AppData.swift`.
- Saved code is stored per problem and language.
- Bundled solution content lives in `FocusApp/Resources/Solutions.json` (85 problems: core plan + sprint list).

## Data Storage
Progress is stored locally in a SwiftData persistent store (default location under Application Support).

## Code Execution & Sandbox
The app uses `Process` to compile/run code. App Sandbox is disabled for the macOS target to allow execution of compiled binaries. If you re-enable sandboxing, you will need a helper tool or XPC service to run code safely.

## Data Journey Visualization Coverage

Currently supported:
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

Known gaps / partial support:
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

## Project Structure
```
FocusApp/
  Packages/
    FocusShared/
      Sources/
        FocusDomain/
        FocusData/
      Tests/
  FocusApp.xcodeproj/
  FocusApp/
    FocusApp.swift
    Models/
    Views/
    Helpers/
    Shared/
  FocusAppTests/
    Interactors/
    Models/
    Presenters/
    Routers/
    Services/
    Stores/
    Support/
  FocusAppIntegrationTests/   # Integration tests (see INTEGRATION_TESTS.md)
    PageObjects/
    Flows/
    Fixtures/
    Support/
    Tests/
  INTEGRATION_TESTS.md
  Docs/
    IOS_APP_EXECUTION_ROADMAP.md
```

## Known Limitations
- macOS only
- Uses a third-party LeetCode REST API (may have rate limits/downtime)
- LeetCode profile must be public for syncing

## Test Coverage
Non-view code coverage (Presenters, Interactors, Routers, Stores, Services, Models) should stay above 95%.

Run tests with coverage:
```bash
xcodebuild test -project FocusApp.xcodeproj -scheme FocusApp -destination 'platform=macOS' -enableCodeCoverage YES
```

Integration test strategy, structure, and execution are documented in `INTEGRATION_TESTS.md`.
iOS/iPad implementation sequencing and package architecture are documented in `Docs/IOS_APP_EXECUTION_ROADMAP.md`.

Shared package scaffolding for cross-platform logic is in `Packages/FocusShared`.

Inspect coverage:
```bash
xcrun xccov view --report path/to/Test-FocusApp.xcresult
```

## License
This project is for personal use. Add a license file if you intend to distribute it.
