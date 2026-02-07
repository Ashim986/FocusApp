# Integration Tests README

This document describes how to execute the integration-test plan for FocusApp. It is designed to keep tests modular, use a Page Object Model (POM), and be ready for macOS now with a clean path to iOS/iPadOS later.

---

## Goals

- **Modular tests**: small, composable page objects and flow helpers
- **POM architecture**: tests read like user flows and remain UI‑structure agnostic
- **Cross‑platform readiness**: shared logic that can support macOS today and iOS/iPadOS later
- **Determinism**: in‑memory/temporary storage and fixed time

---

## Plan (Execution Steps)

1. **Create a dedicated integration test target + scheme**
   - Target: `FocusAppIntegrationTests`
   - Scheme: `FocusApp-Integration`
   - Links against the app target

2. **Build modular test scaffolding**
   - Base harness for dependency wiring
   - Page Objects (POM) layer
   - Fixture helpers (problem content, code snippets, run outputs)

3. **Add Code Environment integration scenarios**
   - Problem selection → content/snippet load
   - Run code → output/diagnostics state
   - Solution fallback path (template generation)

4. **Run and document**
   - Confirm `FocusApp-Integration` scheme runs locally
   - Keep instructions updated for macOS and iOS/iPadOS

---

## Directory Structure (Proposed)

```
FocusAppIntegrationTests/
├── PageObjects/
│   ├── CodingEnvironmentApp.swift
│   ├── ProblemSelectionPage.swift
│   ├── CodeEditorPage.swift
│   └── Shared/
│       └── PageAssertions.swift
├── Flows/
│   └── CodingEnvironmentFlows.swift
├── Fixtures/
│   ├── TestProblemFactory.swift
│   └── TestContentFactory.swift
├── Support/
│   ├── IntegrationTestHarness.swift
│   ├── TestClock.swift
│   └── TempStorage.swift
└── Tests/
    └── CodingEnvironmentIntegrationTests.swift
```

If we decide to keep page objects shared with unit tests, put them in:
`FocusAppTests/Support/PageObjects` and reuse from both targets.

---

## Page Object Model (POM) Guidelines

- **Single responsibility** per page object (one screen/state)
- **Fluent API** for readable flows (`openFromToday().runCode().assertOutput()`)
- **No global state** inside page objects
- **Minimal assertions** in page objects; prefer assertions in tests or a shared `PageAssertions` helper
- **Platform‑aware layer**: keep shared logic in base protocols; macOS/iOS specific behaviors can be in extensions

Example contract (pseudo‑Swift):

```swift
@MainActor
protocol CodeEditorPageType {
    func runCode() -> Self
    func assertOutputContains(_ text: String)
}
```

---

## Modular Test Harness

All integration tests should use a shared harness that provides:

- `InMemoryAppStorage` or temp storage
- `FixedDateProvider`
- `FakeLeetCodeClient` with controllable responses
- `FakeCodeExecutor` or a stubbed `CodeExecutionService`
- `TopicSolutionStore` or `OnDemandSolutionProvider` for fallback

Harness should be in `IntegrationTestHarness.swift` and be reusable per test case.

---

## Cross‑Platform Strategy (macOS → iOS/iPadOS)

- Keep **Core POM protocols** and **fixtures** platform‑agnostic
- Use **platform extensions** for differences in navigation or presentation
- Avoid macOS‑specific types in shared helpers

When iOS/iPadOS targets are added:

- Add a new test target, e.g. `FocusAppIntegrationTests-iOS`
- Add a new scheme, e.g. `FocusApp-Integration-iOS`
- Reuse the same `PageObjects/` and `Fixtures/` modules
- Provide platform‑specific adapters only where needed

---

## Running Integration Tests

### Xcode

1. Select scheme: `FocusApp-Integration`
2. Product → Test

### CLI (macOS)

```bash
xcodebuild test \
  -project FocusApp.xcodeproj \
  -scheme FocusApp-Integration \
  -destination 'platform=macOS'
```

### CLI (iOS/iPadOS, future)

```bash
xcodebuild test \
  -project FocusApp.xcodeproj \
  -scheme FocusApp-Integration-iOS \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Adding a New Integration Test

1. Add/extend fixtures in `Fixtures/`
2. Add or update a Page Object in `PageObjects/`
3. Write the test in `Tests/` using the shared harness
4. Keep the test small: one flow per test

---

## Notes

- Integration tests should remain **deterministic**.
- Do **not** hit real network or disk unless explicitly required.
- Prefer **in‑memory** storage and **fixed clocks**.

