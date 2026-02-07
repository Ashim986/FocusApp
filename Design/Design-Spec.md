# FocusApp Design Spec (Mac + iPhone + iPad)

## Overview
- Goal: deliver a consistent modern UI system across macOS, iPhone, and iPad.
- Coding environment on iOS is read-only for MVP.
- All screens must include explicit dimensions and constraints.
- Focus timer uses Pomodoro pattern (Focus / Short Break / Long Break).

## Roadmap
1. Update design documents (current step).
2. Populate Figma file with screens, components, and constraints.
3. Build iOS and iPad app targets.

---

## Figma File Structure
- Page: Cover
- Page: Foundations
- Page: Components
- Page: Mac Screens
- Page: iPhone Screens
- Page: iPad Screens
- Page: Flows
- Page: Specs

Figma URL: https://www.figma.com/design/294sd4vhQdwEzizccOY4Bn/Focus-App?node-id=0-1

## Platforms And Base Frames
- Mac main window: 1200x760 (resizable).
- Mac floating widget: 350x560.
- iPhone baseline: 393x852 (iPhone 15).
- iPad baseline: 834x1194 (iPad 11").

## Grids And Spacing
- iPhone grid: 4pt base with 8pt spacing scale.
- iPad grid: 8pt base with 8pt spacing scale.
- Mac grid: 8pt base with 8pt spacing scale.

---

## Color Tokens (from Colors.swift)
- appPurple: #6366F1
- appIndigo: #1E1B4B
- appIndigoLight: #312E81
- appGreen: #10B981
- appGreenLight: #D1FAE5
- appCyan: #22D3EE
- appAmber: #F59E0B
- appAmberLight: #FEF3C7
- appRed: #EF4444
- appRedLight: #FEE2E2
- appGray50: #F9FAFB
- appGray100: #F3F4F6
- appGray200: #E5E7EB
- appGray300: #D1D5DB
- appGray400: #9CA3AF
- appGray500: #6B7280
- appGray600: #4B5563
- appGray700: #374151
- appGray800: #1F2937
- appGray900: #111827
- purpleGradient: #6366F1 to #8B5CF6
- indigoGradient: #1E1B4B to #312E81

## Color Variables (Light + Dark)
- Color/Background:
  Light #F9FAFB
  Dark #111827
- Color/Surface:
  Light #FFFFFF
  Dark #1F2937
- Color/SurfaceElevated:
  Light #F3F4F6
  Dark #374151
- Color/Text/Primary:
  Light #111827
  Dark #F9FAFB
- Color/Text/Secondary:
  Light #4B5563
  Dark #D1D5DB
- Color/Divider:
  Light #E5E7EB
  Dark #374151
- Color/Accent:
  Light #6366F1
  Dark #6366F1
- Color/Success:
  Light #10B981
  Dark #10B981
- Color/Warning:
  Light #F59E0B
  Dark #F59E0B
- Color/Error:
  Light #EF4444
  Dark #EF4444

## Typography (SF Pro + SF Mono)
- Title / 32 / Bold
- Headline / 24 / Bold
- Section / 20 / Semibold
- Body / 16 / Regular
- Body Strong / 16 / Semibold
- Subbody / 14 / Regular
- Subbody Strong / 14 / Semibold
- Caption / 12 / Regular
- Caption Strong / 12 / Semibold
- Micro / 11 / Regular
- Micro Strong / 11 / Semibold
- Code / 12 / SF Mono
- Code Micro / 11 / SF Mono

## Visual Direction
- Modern, calm, and focused.
- Primary surfaces: light neutral with subtle gradient highlights.
- Emphasis: indigo and purple accents for active states.
- Cards: soft elevation, 12 to 16 radius, light shadow.
- Icons: simple line icons, consistent 1.5 to 2px stroke weight.

---

## Components To Define
- Primary, secondary, tertiary buttons.
- Chips and tags for difficulty, status, and streaks.
- Cards for Today, Plan, Stats, Focus, and Coding tiles.
- List rows for problems, habits, and progress items.
- Progress bars and ring indicators.
- Code block and read-only editor panel.
- Test case list rows and empty states.
- Data Journey visualization container states.
- Segmented control (Focus / Short Break / Long Break).
- Calendar grid component (month view with date selection).
- Chart components (bar chart, line chart).
- Metric card (label + large value).
- Bottom tab bar (iPhone).
- Sidebar navigation (iPad).

---

## Navigation Patterns

### iPhone
- Bottom tab bar with 5 tabs: Today, Plan, Stats, Focus, Coding.
- Tab icons: home, calendar, bar-chart, lightning-bolt, code-brackets.
- Active tab uses accent color (#6366F1) with filled icon.
- Inactive tabs use gray (#9CA3AF) with outlined icons.
- Top header bar: centered "FocusApp" title + settings gear icon (top-right).
- Settings opens as a pushed view (not a tab).
- Within Coding tab: problem list pushes to problem detail (back chevron navigation).

### iPad
- Persistent left sidebar (width ~260px) with vertical navigation.
- Sidebar items: Today, Plan, Stats, Focus, Coding, Settings (icon + label).
- Active item has accent background highlight.
- User avatar + name + plan badge at sidebar bottom ("John Doe, Pro Plan").
- Floating help button (?) at bottom-right corner.
- Content fills remaining space to the right of sidebar.

### Mac (Existing)
- Tab-based navigation at top (Plan, Today, Stats).
- Coding environment overlays with slide transition.
- Floating widget is a separate always-on-top NSPanel (350x560).
- Settings opens as a sheet.

---

## Current Implementation Status (macOS)

This section documents what the macOS app currently implements, to identify gaps when building for iOS/iPad.

### Today View (Exists - Partial)
- LeetCode sync card with sync button and status message.
- Habits card with 3 toggles: DSA Study, Exercise, Other Study.
- Day cards showing topic, problems list, and completion progress (X/Y).
- Problem rows with difficulty badge, checkbox (read-only, LeetCode-driven), and link.
- **Missing**: greeting, streak badge, daily goal card, focus time card, start focus CTA.

### Plan View (Exists)
- Pre-completed topics banner (green badges for finished topics).
- LeetCode sync card (same as Today).
- Scrolling list of all 15 Day cards with topic, problems, and progress.
- Buffer note card.
- **Missing**: calendar grid UI, date picker, time-blocked schedule items.

### Stats View (Exists - Basic)
- Problems solved: X/total with progress bar.
- Topics completed: X/total with progress bar.
- Habits today: X/3 with progress bar.
- Days left counter.
- Topic breakdown list (each day's name + completed/total + progress bar).
- **Missing**: weekly/monthly charts, focus time metrics, streak counter, session count, difficulty distribution.

### Focus Mode (Exists - Basic Timer)
- Duration selector: preset buttons (30, 60, 90, 120, 180, 240 min) + custom input.
- Active timer: circular progress ring, HH:MM:SS display, pause/resume, end session.
- Completion view: ring shows "Done".
- **Missing**: Pomodoro cycle (Focus/Short Break/Long Break), session counting, focus time persistence, break scheduling, session history.

### Coding Environment (Exists - Full)
- Three-column layout: problem sidebar | code editor | output/tabs panel.
- Problem picker dropdown organized by day/topic.
- Code editor with syntax highlighting (Swift, Python).
- Language toggle (Swift/Python).
- Run and Submit buttons with full code execution.
- Output panel with Result, Console, Debug tabs.
- Hidden AI test case generation (Groq/Gemini).
- LeetCode submission with result polling.
- Data Journey trace visualization.
- Inline focus timer in header (30 min, auto-start).
- Code persistence per problem+language.

### Settings (Exists - macOS Focused)
- Notification settings: daily study reminder, daily habit reminder.
- Plan settings: plan start date picker, reset button.
- LeetCode settings: username, validation, WebView login, auth status.
- AI settings: provider picker (Groq/Gemini), API key, model selector.
- AI test case cache management.
- About section (app name + version).
- Debug log viewer access.
- **Missing**: profile/avatar, appearance toggle, privacy settings, sign out.

### Data Model (AppData.swift)
Fields that exist:
- `progress: [String: Bool]` — problem completion ("day-index": true/false).
- `habits: [String: [String: Bool]]` — daily habits by date.
- `dayOffset: Int` — days advanced ahead of schedule.
- `planStartDate: Date`.
- `leetCodeUsername: String`.
- `savedSolutions: [String: String]` — code per problem+language.
- `submissions: [String: [CodeSubmission]]` — submission history.
- `aiProviderKind`, `aiProviderApiKey`, `aiProviderModel`.
- `leetCodeAuth: LeetCodeAuthSession?`.

---

## New Features Required (For iOS/iPad)

Features shown in mockups that do not exist in the current macOS app. These must be built as part of the iOS/iPad implementation.

### Data Model Additions
New fields needed in the data model:

```
FocusSession {
    id: UUID
    startDate: Date
    durationMinutes: Int
    type: FocusSessionType  // .focus, .shortBreak, .longBreak
    completed: Bool
}

FocusSessionType: enum {
    case focus          // 25 min default
    case shortBreak     // 5 min default
    case longBreak      // 15 min default
}

New AppData fields:
    focusSessions: [FocusSession]           // Completed session history
    dailyFocusGoalMinutes: Int              // Default 120 (2 hours)
    pomodoroFocusMinutes: Int               // Default 25
    pomodoroShortBreakMinutes: Int          // Default 5
    pomodoroLongBreakMinutes: Int           // Default 15
    pomodorosBeforeLongBreak: Int           // Default 4
```

Computed properties (not stored):
- `streak: Int` — consecutive days with at least one completed focus session.
- `totalFocusMinutes: Int` — sum of all completed focus sessions.
- `todayFocusMinutes: Int` — sum of today's completed focus sessions.
- `todaySessionCount: Int` — number of focus sessions completed today.
- `weeklyFocusMinutes: [Int]` — array of 7 daily totals (Mon-Sun) for charts.
- `weeklyProblemsSolved: [Int]` — array of 7 daily counts for charts.

### New UI Features

| Feature | Description | Platform |
|---------|-------------|----------|
| Greeting + streak | "Good Morning, [Name]" with fire emoji streak badge | iPhone, iPad |
| Daily Goal card | Purple gradient card showing X/Y tasks completed with progress bar | iPhone, iPad |
| Focus Time card | Shows today's focus time (e.g. "2h 15m") and remaining vs daily goal | iPhone, iPad |
| Start Focus CTA | Large card/button to launch focus session from Today view | iPhone, iPad |
| Today's Plan list | Task list with strikethrough for completed items, difficulty badges, topic labels | iPhone, iPad |
| Calendar UI | Full month grid with selectable dates, navigation arrows | iPhone, iPad |
| Schedule list | Time-blocked schedule items for selected date | iPhone, iPad |
| Weekly Focus chart | Bar chart showing daily focus minutes (Mon-Sun) | iPhone, iPad |
| Problems Solved chart | Line chart showing daily problems solved (Mon-Sun) | iPhone, iPad |
| Summary metric cards | Total Focus, Current Streak, Problems Solved, Avg Difficulty | iPhone, iPad |
| Pomodoro timer | Focus/Short Break/Long Break segmented control with ring timer | iPhone, iPad |
| Session counter | Badge showing completed sessions count | iPhone, iPad |
| Profile row | User name display in Settings | iPhone, iPad |
| Appearance toggle | Light/Dark mode picker in Settings | iPhone, iPad |
| Sign Out button | Red sign-out action in Settings | iPhone, iPad |

---

## Screen Inventory (All Devices)
- Today
- Plan
- Stats
- Focus
- Settings
- Coding Environment
- Problem Detail
- Sync Status
- Empty States
- Error States

---

## Mac Screen List
- Mac Today
- Mac Plan
- Mac Stats
- Mac Focus Overlay
- Mac Settings
- Mac Coding Environment
- Mac Problem Detail
- Mac Floating Widget
- Mac Debug Logs

---

## iPhone Screen Specifications

### iPhone Today
- **Header**: centered "FocusApp" + settings gear (top-right).
- **Greeting**: "FRIDAY, FEBRUARY 6" (caption, uppercase) + "Good Morning, John" (Title/32/Bold).
- **Streak badge**: orange pill with fire icon + "12 Day Streak" text.
- **Daily Goal card**: purple gradient card (purpleGradient), target icon, "Daily Goal" label, "1/4 Tasks completed" with progress bar.
- **Focus Time card**: white surface card, pulse icon (green), "Focus Time" label, large "2h 15m" value, "35m remaining today" subtitle.
- **Start Focus CTA**: white card with arrow icon (accent), "Start Focus Session" title, "Ready to get in the zone?" subtitle.
- **Today's Plan section**: "Today's Plan" headline + "View Full Plan" link (accent). List of task rows:
  - Completed tasks: green check circle + strikethrough title + difficulty badge + topic + source.
  - Incomplete tasks: dashed circle + normal title + difficulty badge + topic + source.
  - Habit tasks: check circle + title + progress fraction (e.g. "1/4").
- **Tab bar**: bottom, 5 tabs.

### iPhone Today (Scrolled)
- Continues below fold: Focus Time card, CTA card, Today's Plan list visible after scrolling past greeting and Daily Goal.

### iPhone Plan
- **Header**: "Study Plan" (Headline/24/Bold).
- **Calendar card**: white surface, month/year title ("February 2026"), left/right navigation arrows, 7-column grid (SU-SA), date cells with today highlighted in accent circle.
- **Selected date label**: "You selected Feb 7, 2026." (secondary text below calendar).
- **Schedule card**: "Schedule for February 7th" title. Time-blocked rows:
  - Active row: accent-tinted background, bold time (e.g. "09:00 AM"), title, subtitle.
  - Normal row: white background, regular time, title, subtitle.
  - Faded row: reduced opacity for past/future items.

### iPhone Stats
- **Header**: "Your Statistics" (Headline/24/Bold).
- **Weekly Focus Time card**: bar chart, purple bars, x-axis Mon-Sun, y-axis hours.
- **Problems Solved card**: line chart, green line with dot markers, x-axis Mon-Sun, y-axis count.
- **Metric cards** (2x2 grid):
  - Total Focus: "34h 12m".
  - Current Streak: "12 Days".
  - Problems Solved: "45".
  - Avg. Difficulty: "Medium".

### iPhone Focus (Pomodoro - Variant A)
- **Header**: "Focus" title + "Sessions: 0" badge (top-right).
- **Timer card**: light pink/rose background (#FEE2E2 or similar).
  - Segmented control at top: Focus (selected, dark pill) / Short Break / Long Break. Each segment has a small icon.
  - Large circular ring timer (gray track, red/accent progress indicator dot at top).
  - Center: large time display "25:00" + status label "PAUSED" or "RUNNING".
  - Below ring: red "Start" button (or "Pause" when running) + gray reset button.
- **Current Focus section**: "CURRENT FOCUS" label + "No active tasks" (or linked task name).
- **Tasks section**: "Tasks 0" card listing focus-linked tasks.

### iPhone Coding - Problem List
- **Search bar**: "Search problems..." with magnifying glass icon.
- **Problem cards**: white surface cards, each showing:
  - Problem title (Body Strong/16/Semibold).
  - Difficulty badge: Easy (green, #D1FAE5 bg), Medium (amber, #FEF3C7 bg), Hard (red, #FEE2E2 bg).
  - Completion indicator: green checkmark circle (solved) or empty gray circle (unsolved).

### iPhone Coding - Problem Detail
- **Back navigation**: chevron + problem title.
- **Tab bar**: Desc / Solution / Code (horizontal, underline active tab in accent).
- **Desc tab**: problem title (Body Strong), difficulty badge, description text (Body/16).
- **Solution tab**: solution write-up content (placeholder in mockup).
- **Code tab**: dark-themed read-only code viewer.
  - Header: language label ("TypeScript") + lock icon + "Read-only" label.
  - Code with syntax highlighting and line numbers.
  - No Run/Submit buttons (read-only MVP).

### iPhone Settings
- **Header**: "Settings" (Headline/24/Bold).
- **Account section**: "ACCOUNT" section header (Caption Strong, uppercase, secondary color).
  - Profile row: person icon + "Profile" + name subtitle + chevron.
  - Security row: shield icon + "Security" + "Password, 2FA" subtitle + chevron.
- **Preferences section**: "PREFERENCES" section header.
  - Notifications row: bell icon + "Notifications" + "On" status + chevron.
  - Appearance row: moon icon + "Appearance" + "Light" status + chevron.
- **Sign Out button**: full-width, light red background (#FEE2E2), red text, centered.

---

## iPad Screen Specifications

All iPad screens share a persistent left sidebar:
- **Sidebar** (~260px width): "FocusApp" logo/title at top, navigation items (Today, Plan, Stats, Focus, Coding, Settings) with icons, active item has accent (#6366F1) background highlight with rounded corners, user profile at bottom (avatar initials circle "JD" + "John Doe" + "Pro Plan" subtitle).
- **Floating help button**: "?" circle at bottom-right corner of the main content area.

### iPad Today
- **Layout**: sidebar + main content (single scrollable area).
- **Top row** (horizontal card strip):
  - Daily Goal card (purple gradient, same as iPhone but smaller).
  - Focus Time card (white surface, same as iPhone but smaller).
  - Start Focus Session card (white surface with arrow icon).
- **Today's Plan section**: "Today's Plan" + "View Full Plan" link. Same task row format as iPhone but wider rows.

### iPad Plan
- **Layout**: sidebar + two-column content.
- **Left column** (~50%): Calendar card (same month grid as iPhone, larger cells).
- **Right column** (~50%): "Schedule for February 7th" with time-blocked schedule rows. Additional schedule item visible: "02:00 PM Mock Interview - System Design with Peer" (faded).

### iPad Stats
- **Layout**: sidebar + main content.
- **Chart row** (two charts side by side):
  - Weekly Focus Time bar chart (left, ~50%).
  - Problems Solved line chart (right, ~50%).
- **Metric cards row** (4 cards in a single horizontal row):
  - Total Focus: "34h 12m".
  - Current Streak: "12 Days".
  - Problems Solved: "45".
  - Avg. Difficulty: "Medium".

### iPad Focus
- **Layout**: sidebar + centered content.
- **Content**: "Deep Work Session" title + "Stay focused and track your progress." subtitle.
- **Timer**: large purple ring (same as iPhone Variant A Pomodoro, but uses purple accent ring on iPad).
- **Controls**: purple play button + gray reset button centered below ring.
- **Stats row**: "3 SESSIONS" + "75m TOTAL FOCUS" (two stats side by side below controls).
- **Note**: iPad uses the same Pomodoro segmented control when the timer card is expanded. The default view shows the simplified "Deep Work Session" header.

### iPad Coding Environment
- **Layout**: sidebar + three-panel content.
- **Left panel** (~280px): "Coding Environment" header + search input + problem list (same card format as iPhone: title, difficulty badge, checkmark).
- **Center panel** (flexible): main content area. Shows "Select a problem" placeholder when nothing is selected. Shows problem description when a problem is selected.
- **Right panel** (~280px): "OUTPUT / TEST CASES" header. Shows test case details (Case 1: Input, Output) and Console output.
- **Run button**: top-right corner, accent background with play icon.
- **Bottom section**: "DESCRIPTION" panel below center content showing problem description.
- **Note**: Code is read-only on iOS MVP. Run button visible but execution limited.

### iPad Settings
- **Layout**: sidebar + main content (centered, max-width ~700px).
- **Same structure as iPhone Settings** but with more horizontal space.
- Account section, Preferences section, Sign Out button.

---

## iOS Coding Environment (Read-Only MVP)
- Problem list with search and filter by difficulty.
- Problem detail tabs: Description, Solution, Code.
- Saved code viewer with syntax highlighting (dark theme, read-only).
- Test cases view only (no editing).
- Output panel in disabled/placeholder state.
- Data Journey visualization in read-only playback mode.
- No Run or Submit execution (code execution requires macOS shell access).
- Language display label but no language toggle (shows saved language).

---

## Features In Current App Not In Mobile Mockups

These macOS features are not shown in the mobile mockups but should be considered for future mobile phases:

| Feature | macOS Status | Mobile Plan |
|---------|-------------|-------------|
| LeetCode sync (GraphQL) | Full sync with auto-mark | Phase 2: add sync to mobile |
| AI test case generation | Groq/Gemini up to 50 per problem | Phase 2: remote execution service |
| Code execution (Run/Submit) | Full Swift/Python local execution | Phase 2: remote execution service |
| Data Journey visualization | Full trace visualization | Phase 2: read-only playback on mobile |
| Debug log viewer | Full log viewer in Settings | Not planned for mobile |
| AI provider settings | Provider picker + API key + model | Phase 2: shared via iCloud or account |
| Floating widget | macOS NSPanel 350x560 | Not applicable on mobile |
| Auto-instrumentation | Trace.step() injection | Not applicable (macOS execution only) |
| LeetCode WebView login | In-app browser auth session | Phase 2: ASWebAuthenticationSession on iOS |

---

## Constraints Guidance (All Platforms)
- Use Auto Layout for all components.
- Define padding and spacing on every container.
- Specify min and max widths for columns and sidebars.
- Use constraints for safe area and window resize behavior.

## Recommended Layout Constraints
- Mac main layout: left sidebar fixed width 280, main content flexible, right panel optional 320.
- iPhone: single-column scroll with sticky top header. 16px horizontal padding. Cards full-width with 12px gap.
- iPad: persistent sidebar ~260px. Content area fills remaining space.
- iPad two-column views (Plan, Stats): 50/50 split or 60/40 with 16px gap.
- iPad Coding Environment: left list 280, editor area flexible, output panel fixed 280.
- All cards: 12-16pt corner radius, 1px border (Color/Divider), 8-16px inner padding.
- Tab bar (iPhone): 49pt height, safe area bottom inset.
- Sidebar (iPad): full height, 260px width, divider line on right edge.

---

## Phased Implementation

### Phase 1: iOS/iPad MVP
- Shared data model with new focus session fields.
- iPhone and iPad navigation (tab bar / sidebar).
- Today view with greeting, streak, daily goal, focus time, plan list.
- Plan view with calendar UI and schedule list.
- Stats view with charts and metric cards.
- Focus timer with Pomodoro (Focus / Short Break / Long Break).
- Session persistence and streak tracking.
- Coding environment (read-only): problem list, detail tabs, saved code viewer.
- Settings: profile display, notifications, appearance toggle.
- LeetCode sync (reuse existing service).

### Phase 2: Enhanced Mobile
- Remote code execution service (Run/Submit from mobile).
- Data Journey read-only playback on mobile.
- iCloud sync for shared progress across Mac and iOS.
- LeetCode login via ASWebAuthenticationSession.
- AI test case generation on mobile (via remote API).
- Push notifications for focus reminders and achievements.

### Phase 3: Future
- Widgets (iOS home screen, lock screen).
- Apple Watch companion (focus timer, quick stats).
- Shortcuts integration.
- Share extensions for problems.

---

## End-To-End Flow Diagram
- FigJam link: https://www.figma.com/online-whiteboard/create-diagram/50980311-5f51-41f1-8025-0aee74095d7b
