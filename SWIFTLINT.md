# SwiftLint Setup Guide

## Installation

### Option 1: Homebrew (Recommended)

```bash
brew install swiftlint
```

### Option 2: Mint

```bash
mint install realm/SwiftLint
```

### Option 3: Download Binary

Download from [SwiftLint Releases](https://github.com/realm/SwiftLint/releases)

## Xcode Build Phase Setup

1. Open `FocusApp.xcodeproj` in Xcode
2. Select the **FocusApp** target
3. Go to **Build Phases** tab
4. Click **+** → **New Run Script Phase**
5. Rename it to **"SwiftLint"**
6. Drag it to run **after "Compile Sources"**
7. Paste this script:

```bash
if command -v swiftlint &> /dev/null; then
    swiftlint lint --config "${SRCROOT}/.swiftlint.yml"
else
    echo "warning: SwiftLint not installed. Run: brew install swiftlint"
fi
```

8. Uncheck **"Based on dependency analysis"** (optional, for consistent linting)

## Running SwiftLint

### Command Line

```bash
# Lint the project
swiftlint lint

# Auto-fix correctable issues
swiftlint lint --fix

# Analyze for unused code (slower)
swiftlint analyze --compiler-log-path /path/to/compile_commands.json
```

### In Xcode

SwiftLint runs automatically on every build after setup.

## Configuration Overview

The `.swiftlint.yml` configuration enforces:

### Code Style
- **Line length**: Warning at 120 chars, error at 200
- **Sorted imports**: Keep imports alphabetically sorted
- **Trailing commas**: Required in multi-line collections
- **Vertical whitespace**: Max 2 empty lines

### Safety
- **Force unwrapping**: Warning (avoid `!`)
- **Force cast**: Warning (avoid `as!`)
- **Force try**: Warning (avoid `try!`)
- **Implicitly unwrapped optionals**: Warning

### Organization
- **Type contents order**: Enforces consistent member ordering
- **Modifier order**: Consistent access control placement
- **Closure formatting**: Proper indentation and spacing

### Custom Rules
- **No print statements**: Use proper logging
- **No hardcoded colors**: Use `Colors.swift`
- **Presenter @MainActor**: Presenters must be on main actor
- **TODO with owner**: `// TODO(username): description`

## Fixing Common Warnings

### Sorted Imports
```swift
// Before (warning)
import SwiftUI
import AppKit
import Foundation

// After (correct)
import AppKit
import Foundation
import SwiftUI
```

### Trailing Comma
```swift
// Before (warning)
let items = [
    "one",
    "two"
]

// After (correct)
let items = [
    "one",
    "two",
]
```

### Force Unwrapping
```swift
// Before (warning)
let value = optional!

// After (correct)
guard let value = optional else { return }
// or
if let value = optional { ... }
```

### Line Length
```swift
// Before (warning - too long)
func someFunction(parameter1: String, parameter2: Int, parameter3: Bool, parameter4: Double) -> String {

// After (correct - multiline)
func someFunction(
    parameter1: String,
    parameter2: Int,
    parameter3: Bool,
    parameter4: Double
) -> String {
```

## Disabling Rules

### Inline (single line)
```swift
let value = optional! // swiftlint:disable:this force_unwrapping
```

### Block
```swift
// swiftlint:disable force_cast
let view = object as! UIView
let label = object as! UILabel
// swiftlint:enable force_cast
```

### File-wide
```swift
// swiftlint:disable:file line_length
```

## CI Integration

For GitHub Actions:

```yaml
- name: SwiftLint
  run: |
    brew install swiftlint
    swiftlint lint --strict --reporter github-actions-logging
```

## Updating Rules

Edit `.swiftlint.yml` to:
- Add rules to `opt_in_rules` to enable
- Add rules to `disabled_rules` to disable
- Adjust thresholds in rule configurations

See all rules: `swiftlint rules`
