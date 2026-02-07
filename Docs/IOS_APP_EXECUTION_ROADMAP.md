# iOS/iPad Execution Roadmap

This roadmap defines the implementation order for shipping iOS and iPadOS while keeping macOS stable.

## Architecture Decision
- Use **platform app targets** for shipping apps (`macOS`, `iOS`).
- Use **shared Swift packages** for reusable logic (`Packages/FocusShared` + `DSFocusFlow`).
- Keep iPad as layout adaptation inside the iOS target.

## Module Boundaries
- `FocusDomain` (shared package)
  - Entities, value objects, plan/problem models, pure rules.
- `FocusData` (shared package)
  - Slug parsing, sync orchestration, repository contracts, storage adapters.
- `DSFocusFlow` (external package)
  - Design system components and tokens.
- App targets (`FocusApp` macOS, future iOS target)
  - Composition root, navigation shell, platform-specific APIs.

## Execution Order
1. **Stabilize shared modules**
   - Expand `FocusDomain` and `FocusData` coverage.
   - Replace duplicate app-local entities progressively.
2. **Create iOS app target + scheme**
   - Add iOS target in `FocusApp.xcodeproj`.
   - Wire dependency injection to shared modules.
3. **Port feature screens in sequence**
   - Today
   - Plan
   - Stats
   - Focus
   - Coding
   - Settings
4. **Add iOS/iPad integration test lane**
   - New scheme: `FocusApp-Integration-iOS`
   - Reuse POM test scaffolding from `INTEGRATION_TESTS.md`.
5. **Harden release quality**
   - Add snapshot tests for DS-heavy screens.
   - Add contract tests for LeetCode sync and plan progression.
   - CI matrix: macOS app tests + iOS simulator tests.

## Immediate Migration Slice (next coding step)
1. Import `FocusDomain` in `DSAPlan` model layer.
2. Replace `LeetCodeSlugExtractor` calls in store sync path with `LeetCodeProgressSynchronizer`.
3. Keep behavior identical; add regression tests before removing old helpers.
