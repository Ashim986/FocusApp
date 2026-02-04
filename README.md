# FocusApp

FocusApp is a native macOS study companion for Data Structures & Algorithms preparation. It tracks a 13-day study plan with 65 LeetCode problems, daily habits, focus tools, and a built-in coding environment. The app syncs solved problems from LeetCode to keep progress accurate.

## Features
- LeetCode-driven progress sync (REST API)
- Automatic refresh on username change, hourly, and at day start
- Split-view coding workspace with problem list, details, and output panel
- Swift + Python editors with test case execution
- Floating always-on-top widget
- Daily habits and progress tracking
- Focus mode timer overlay
- Tomorrow preview and auto-carryover for unsolved problems

## Requirements
- macOS 13.0+
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

## Data Storage
Progress is stored locally at:
```
~/.dsa-focus-data.json
```

## Project Structure
```
FocusApp/
  FocusApp.xcodeproj/
  FocusApp/
    FocusApp.swift
    Models/
    Views/
    Helpers/
    Shared/
```

## Known Limitations
- macOS only
- Uses a third-party LeetCode REST API (may have rate limits/downtime)
- LeetCode profile must be public for syncing

## License
This project is for personal use. Add a license file if you intend to distribute it.
