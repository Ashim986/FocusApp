# FocusShared

Local shared package for multi-platform FocusApp development.

## Targets
- `FocusDomain`
  - Core entities/value objects shared by macOS, iOS, and iPadOS.
  - Current scope: `Difficulty`, `Problem`, `StudyDay`, `StudyPlan`, `ProblemKey`.
- `FocusData`
  - Shared data-side utilities and orchestration.
  - Current scope: `LeetCodeSlugParser`, `LeetCodeProgressSynchronizer`.

## Why this package exists
- Keep app targets thin (`FocusApp-macOS`, `FocusApp-iOS`) and move reusable logic out of UI targets.
- Reduce duplicate implementation when iOS/iPadOS app targets are added.
- Make core behavior testable without loading the app UI.

## Current status
- Scaffolding complete for Domain + Data modules.
- Unit tests included for deterministic behavior.
- Not yet wired into `FocusApp.xcodeproj` app target imports (migration staged).

## Run tests
```bash
cd Packages/FocusShared
swift test
```

## Next migration steps
1. Import `FocusDomain` into plan-related model files and remove duplicate local entity definitions.
2. Swap `AppStateStore.applySolvedSlugs` logic to use `LeetCodeProgressSynchronizer`.
3. Move shared date/progress contracts into `FocusData`.
4. Keep platform shell concerns (AppKit/SwiftUI composition) in app targets.
