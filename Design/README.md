# FocusApp Design Reference

Design documentation for the iOS/iPad port of FocusApp, reconciled against the current macOS implementation.

## Design Decisions
- **Focus Timer**: Pomodoro (Variant A) — Focus / Short Break / Long Break segmented control with session counting. Pink/rose timer card on iPhone.
- **Coding Environment (iOS MVP)**: Read-only. No code execution. Syntax-highlighted code viewer with dark theme.
- **Navigation**: iPhone uses bottom tab bar (5 tabs). iPad uses persistent left sidebar.

## Platforms
| Platform | Status | Notes |
|----------|--------|-------|
| macOS | Shipped | Full feature set with code execution |
| iPhone | Design ready | Mockups captured, spec written |
| iPad | Design ready | Mockups captured, spec written |

## Screen Inventory

### iPhone Screens (from mockups)

| Screen | Description | Status vs macOS |
|--------|-------------|-----------------|
| Today | Greeting, streak, daily goal card, focus time card, start focus CTA, today's plan list | **New**: greeting, streak, daily goal, focus time card, CTA. **Existing**: problem list (reformatted). |
| Today (scrolled) | Below-fold: plan list with completed (strikethrough) and pending tasks | **New**: strikethrough style, task categories (LeetCode, reading, PR review, health). |
| Plan | Calendar month grid + daily schedule list with time blocks | **New**: calendar UI, time-blocked schedule. **Existing**: day/topic data (reformatted). |
| Stats | Weekly Focus Time bar chart, Problems Solved line chart, 4 metric cards | **New**: all charts, focus time metrics, streak counter, avg difficulty. **Existing**: problems solved count. |
| Focus | Pomodoro timer with Focus/Short Break/Long Break segmented control, ring timer, session counter, tasks list | **New**: Pomodoro cycle, session counting, task linking. **Existing**: timer ring (redesigned). |
| Coding - Problem List | Search bar + problem cards with difficulty badges and completion checkmarks | **Existing**: problem list (reformatted for mobile single-column). |
| Coding - Problem Detail (Desc) | Back nav, Desc/Solution/Code tabs, problem title, difficulty, description | **Existing**: same data, mobile layout. |
| Coding - Problem Detail (Solution) | Solution write-up content | **Existing**: solution data from Solutions.json. |
| Coding - Problem Detail (Code) | Dark-themed read-only code viewer with syntax highlighting, lock icon | **New**: read-only mode, lock icon. **Existing**: syntax highlighting, saved code. |
| Settings | Profile, Security, Notifications, Appearance, Sign Out | **New**: profile, security, appearance toggle, sign out. **Existing**: notifications. |

### iPad Screens (from mockups)

| Screen | Description | Layout |
|--------|-------------|--------|
| Today | Horizontal card strip (goal, focus, CTA) + plan list | Sidebar + single column |
| Plan | Calendar grid + schedule list side by side | Sidebar + two columns |
| Stats | Two charts side by side + 4 metric cards in a row | Sidebar + main content |
| Focus | Deep Work Session with large purple ring timer, session stats | Sidebar + centered content |
| Coding | Problem list + center content + output/test panel | Sidebar + three panels |
| Settings | Same as iPhone but wider layout | Sidebar + centered content |

## Gap Analysis: Mockups vs Current App

### Features the Mockups Add (Not in macOS)
- Greeting with user name and date
- Streak counter (consecutive active days)
- Daily goal visualization (X/Y tasks with progress bar)
- Focus time tracking and display (persistent across sessions)
- Pomodoro timer cycle (Focus / Short Break / Long Break)
- Session counting and persistence
- Calendar month grid with date selection
- Time-blocked daily schedule
- Weekly charts (focus time bar chart, problems solved line chart)
- Summary metric cards (total focus, streak, problems solved, avg difficulty)
- Profile and security settings
- Appearance (dark/light) toggle
- Sign out functionality
- iPad sidebar navigation with user avatar
- Floating help button (iPad)

### Features in macOS Not in Mockups
These exist in the macOS app but are intentionally omitted from mobile MVP:
- Code execution (Run/Submit) — requires local shell, not available on iOS
- AI test case generation — requires API keys and execution
- Data Journey trace visualization — complex, deferred to Phase 2
- Debug log viewer — developer tool, not user-facing on mobile
- AI provider settings — deferred to Phase 2
- Floating widget — macOS-only window type
- Auto-instrumentation — requires macOS execution
- LeetCode WebView login — needs ASWebAuthenticationSession adaptation

### Data Model Gaps
The current `AppData.swift` lacks fields needed by the mockup designs:
- No `FocusSession` model (session history)
- No focus time aggregation (daily, weekly, total)
- No streak computation
- No Pomodoro configuration (focus/break durations)
- No daily focus goal setting

See `Design-Spec.md` > "Data Model Additions" for the proposed schema.

## Visual Design Language
- Soft card-based layout with generous whitespace
- Rounded corners (12-16pt radius)
- Subtle elevation/shadows on cards
- Primary accent: violet/indigo (#6366F1)
- Success: green (#10B981) for Easy badges and completion
- Warning: amber (#F59E0B) for Medium badges
- Error: red (#EF4444) for Hard badges and Sign Out
- Charts: minimal axis styling, soft dashed grid lines
- Purple gradient for Daily Goal card
- Pink/rose background for Pomodoro timer card
- Bottom tab bar: outlined icons, accent fill for active tab
- iPad sidebar: full-height, accent highlight for active item

## Key Files
- `Design-Spec.md` — Full specification with screen details, color tokens, typography, constraints
- `FOCUSAPP_FIGMA_URL.md` — Figma file URL
- `Exports/EXPORT_CHECKLIST.md` — Asset export targets

## Roadmap
1. **Design docs** (done) — Reconcile mockups with current implementation.
2. **Figma population** — Create screens and components in Figma file.
3. **iOS/iPad build** — Implement SwiftUI views with shared data model.
