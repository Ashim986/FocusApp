# DSA Focus App - Development Guide

## Project Overview

DSA Focus is a native macOS study companion app for Data Structures & Algorithms preparation. It helps track a 13-day study plan with 65 LeetCode problems, daily habits, and provides focus tools. The app automatically syncs with your LeetCode account to track solved problems.

## Project Structure

```
dsa-focus-app/
├── DSAFocusApp/
│   ├── DSAFocusApp.xcodeproj/      # Xcode project
│   └── DSAFocusApp/                # Main app source
│       ├── DSAFocusApp.swift       # App entry point with MenuBarExtra
│       ├── DSAFocusApp.entitlements
│       ├── Assets.xcassets
│       ├── Models/
│       │   ├── AppData.swift           # Data model for progress/habits
│       │   ├── DataStore.swift         # ObservableObject for state management
│       │   ├── DSAPlan.swift           # 13-day study plan definition
│       │   ├── NotificationManager.swift   # Local notifications
│       │   └── LeetCodeService.swift   # LeetCode API sync service
│       ├── Views/
│       │   ├── ContentView.swift       # Main tabbed interface
│       │   ├── PlanView.swift          # Full study plan view
│       │   ├── TodayView.swift         # Today's tasks view
│       │   ├── StatsView.swift         # Progress statistics
│       │   ├── FocusOverlay.swift      # Focus mode timer overlay
│       │   ├── FloatingWidgetView.swift    # Floating widget content
│       │   ├── DayCard.swift           # Day card component
│       │   ├── ProblemRow.swift        # Problem row component
│       │   └── SettingsView.swift      # Settings view
│       ├── Helpers/
│       │   ├── Colors.swift            # Color definitions
│       │   └── FloatingPanelController.swift   # NSPanel manager
│       └── Shared/
│           └── SharedDataStore.swift   # Shared data access
└── CLAUDE.md                       # This file
```

## Running the App

```bash
# Open in Xcode
open DSAFocusApp/DSAFocusApp.xcodeproj

# Press Cmd+R to run
```

## Key Features

- **LeetCode-Driven Progress**: Problem completion is synced from LeetCode (no manual checkboxes)
- **LeetCode Auto-Sync**: Automatically syncs solved problems from your LeetCode account on app launch
- **Username Settings**: Change LeetCode username via in-app settings with validation
- **Advance Early**: Complete all problems to unlock next day's set early
- **Floating Widget**: Interactive overlay showing progress, problems, and habits (top-left corner)
- **Tomorrow's Preview**: Collapsible section showing upcoming problems and carryover from today
- **Auto-Carryover**: Unsolved problems from today automatically appear in tomorrow's section
- **Menu Bar Icon**: Brain icon for quick widget toggle and sync
- **Keyboard Shortcuts**: `Cmd+Shift+W` (toggle widget), `Cmd+R` (sync LeetCode)
- **Auto-launch**: Widget appears automatically on app start
- **Focus Mode**: Full-screen timer overlay for distraction-free studying
- **Progress Tracking**: Track completed problems and daily habits
- **Notifications**: Periodic reminders to stay on track

## Floating Widget

The floating widget (300x420px) is an always-on-top, draggable NSPanel window.

### Features
- **Header**: Title, sync button (🔄), settings button (⚙️), close button (✕)
- **Settings Panel**: Collapsible panel to change LeetCode username with validation
- **Progress Section**: Overall progress ring, current day/topic, habits count
- **Problem List**: Today's 5 problems with status indicators and LeetCode links
- **Habits**: Toggle buttons for DSA, Exercise, Other
- **Tomorrow Section**: Collapsible preview of tomorrow's topic and problems
- **Advance Button**: "Start Day X" appears when all problems are solved

### Interactions
| Action | Result |
|--------|--------|
| Click problem name | Open LeetCode in browser |
| Click 🔄 | Sync with LeetCode to update solved status |
| Click ⚙️ | Open/close settings panel |
| Click ✕ | Hide widget |
| Drag widget | Reposition on screen |
| Click "Tomorrow" | Expand/collapse tomorrow's preview |
| Click "Start Day X" | Advance to next day's problems (when all solved) |

### Settings Panel

Click the ⚙️ gear icon to open settings:

**Username Configuration**
- Text field to enter your LeetCode username
- "Save & Sync" button validates and saves
- Press Enter to save quickly

**Username Validation**
- App verifies username exists on LeetCode before saving
- Shows loading spinner while checking
- Visual feedback:
  - ✅ Green border + "Valid" = Username found, saved
  - ❌ Red border + "User not found" = Invalid username, not saved
  - ⚠️ Orange warning = Network/API error
- Validation resets when you start typing again

### LeetCode-Driven Workflow

Problem checkboxes are **read-only** and driven entirely by LeetCode sync:

1. **Solve on LeetCode**: Open problem link, solve it on leetcode.com
2. **Sync**: Click 🔄 or press `Cmd+R` to fetch your latest submissions
3. **Auto-update**: Checkmarks appear for problems you've solved
4. **Advance**: When all 5 problems are solved, "Start Day X" button appears
5. **Next Day**: Click to advance and get the next day's problems early

This ensures your progress is always accurate with your actual LeetCode submissions.

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

The app automatically syncs with LeetCode to mark problems you've already solved.

### How It Works
1. On app launch, fetches your accepted submissions from LeetCode API
2. Matches problem slugs (e.g., "reverse-linked-list") with study plan URLs
3. Automatically marks matching problems as solved locally
4. Shows sync status: "Synced X new problems" or "X problems up to date"

### Sync Methods
| Method | How |
|--------|-----|
| Auto (on launch) | Happens 1 second after app starts |
| Widget button | Click 🔄 icon in widget header |
| Menu bar | Brain icon → "Sync with LeetCode" |
| Keyboard | `Cmd+R` |

### Configuration
- **Username**: Configurable via in-app settings (click ⚙️ in widget header)
- **Default Username**: `ashim986`
- **API**: Uses `alfa-leetcode-api.onrender.com` (third-party, free, no auth required)

### Changing Username

**Via App (Recommended)**
1. Click ⚙️ gear icon in widget header
2. Enter your LeetCode username
3. Click "Save & Sync" or press Enter
4. App validates username exists before saving
5. If valid, saves and syncs automatically

**Via Code (Alternative)**
Edit default in `DSAFocusApp/DSAFocusApp/Models/AppData.swift`:
```swift
self.leetCodeUsername = "your-leetcode-username"
```

## Data Storage

Progress is stored at:
```
~/.dsa-focus-data.json
```

### Data Structure
```json
{
  "progress": {"1-0": true, "1-1": true},  // "day-problemIndex": solved
  "habits": {"2026-02-03": {"dsa": true}}, // date: {habit: done}
  "dayOffset": 0,                           // Days advanced ahead of schedule
  "leetCodeUsername": "ashim986"            // LeetCode username for syncing
}
```

| Field | Purpose |
|-------|---------|
| `progress` | Tracks which problems are solved (day-index: true/false) |
| `habits` | Daily habit completion by date |
| `dayOffset` | Days advanced ahead of schedule (early completion) |
| `leetCodeUsername` | LeetCode username for API sync |

## Key Files to Modify

| File | Purpose |
|------|---------|
| `Models/DSAPlan.swift` | Study plan topics, problems, URLs |
| `Models/LeetCodeService.swift` | LeetCode username |
| `Views/FloatingWidgetView.swift` | Widget UI, tomorrow's preview, carryover logic |
| `Helpers/FloatingPanelController.swift` | Widget position and size |

### View Components in FloatingWidgetView.swift

| Component | Purpose |
|-----------|---------|
| `FloatingWidgetView` | Main widget container with all sections |
| `ProblemRowWidget` | Today's problem row with status indicator (LeetCode-driven) |
| `HabitToggle` | Habit button (DSA, Exercise, Other) |
| `CarryoverProblemRow` | Unsolved problem from today (orange styling) |
| `TomorrowProblemRow` | Tomorrow's problem preview (muted styling) |

## Architecture

### Floating Widget (NSPanel)
Uses `NSPanel` for the floating widget because:
- No paid Apple Developer account required
- More interactive than WidgetKit (buttons, scrolling)
- Draggable and always-on-top

```swift
// Toggle widget
FloatingPanelController.shared.toggle()

// Show/hide
FloatingPanelController.shared.show()
FloatingPanelController.shared.hide()
```

### State Management
- `DataStore` - Main ObservableObject with `@Published` properties
- `SharedDataStore` - Static methods for file I/O
- `LeetCodeService` - Singleton for API calls

### LeetCode Service
```swift
// Trigger sync
dataStore.syncWithLeetCode()

// Check status
dataStore.isSyncing        // true while syncing
dataStore.lastSyncResult   // "Synced 3 new problems"
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd+Shift+W` | Toggle floating widget |
| `Cmd+R` | Sync with LeetCode |
| `Cmd+Q` | Quit app |

## Common Code Tasks

### Toggle widget
```swift
FloatingPanelController.shared.toggle()
```

### Sync with LeetCode
```swift
dataStore.syncWithLeetCode()
```

### Validate and update username
```swift
dataStore.validateAndUpdateUsername("newusername") { isValid in
    if isValid {
        // Username saved and ready to sync
    } else {
        // Username not found on LeetCode
    }
}
```

### Check validation status
```swift
dataStore.isValidatingUsername      // true while checking
dataStore.usernameValidationResult  // .none, .valid, .invalid, .error(msg)
```

### Advance to next day (when all problems solved)
```swift
dataStore.advanceToNextDay()
```

### Get current day (with offset)
```swift
let day = dataStore.currentDayNumber()  // Includes any advance offset
```

### Mark habit done
```swift
dataStore.toggleHabit("dsa")      // or "exercise", "other"
```

### Get current progress
```swift
let percentage = SharedDataStore.progressPercentage(from: data)
let topic = SharedDataStore.todaysTopic()
let day = SharedDataStore.currentDayNumber()
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
    dataStore.isProblemCompleted(day: currentDayNumber, problemIndex: index) ? nil : (index, problem)
}
```

## Known Limitations

1. **macOS Only**: Native macOS app, won't run on iOS
2. **Sandbox Disabled**: Required for home directory file access
3. **LeetCode API**: Third-party API may have rate limits or downtime
4. **Public Profile**: Your LeetCode profile must be public for sync to work

## Build & Distribution

### Development
1. Open `DSAFocusApp.xcodeproj` in Xcode
2. Press `Cmd+R` to build and run

### Release Build
1. Product > Archive
2. Export as "Copy App"
3. No code signing required for personal use

### Requirements
- macOS 13.0+
- Xcode 15.0+
- Swift 5.0
- Internet connection (for LeetCode sync)
