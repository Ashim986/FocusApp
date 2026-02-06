# FocusApp Design Spec (Mac + iPhone + iPad)

## Overview
- Goal: deliver a consistent modern UI system across macOS, iPhone, and iPad.
- Coding environment on iOS is read-only for MVP.
- All screens must include explicit dimensions and constraints.

## Figma File Structure
- Page: Cover
- Page: Foundations
- Page: Components
- Page: Mac Screens
- Page: iPhone Screens
- Page: iPad Screens
- Page: Flows
- Page: Specs

## Platforms And Base Frames
- Mac main window: 1200x760 (resizable).
- Mac floating widget: 350x560.
- iPhone baseline: 393x852 (iPhone 15).
- iPad baseline: 834x1194 (iPad 11").

## Grids And Spacing
- iPhone grid: 4pt base with 8pt spacing scale.
- iPad grid: 8pt base with 8pt spacing scale.
- Mac grid: 8pt base with 8pt spacing scale.

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

## Components To Define
- Primary, secondary, tertiary buttons.
- Chips and tags for difficulty, status, and streaks.
- Cards for Today, Plan, Stats, Focus, and Coding tiles.
- List rows for problems, habits, and progress items.
- Progress bars and ring indicators.
- Code block and read-only editor panel.
- Test case list rows and empty states.
- Data Journey visualization container states.

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

## iPhone Screen List
- iPhone Today
- iPhone Plan
- iPhone Stats
- iPhone Focus
- iPhone Settings
- iPhone Coding Environment (read-only)
- iPhone Problem Detail

## iPad Screen List
- iPad Today
- iPad Plan
- iPad Stats
- iPad Focus
- iPad Settings
- iPad Coding Environment (split view)
- iPad Problem Detail

## iOS Coding Environment (Read-Only MVP)
- Problem list and search/filter.
- Problem detail tabs: Description, Editorial, Solution, Submissions.
- Saved code viewer with syntax highlighting.
- Test cases view only.
- Output panel in disabled state.
- Data Journey visualization in read-only playback.

## Constraints Guidance (All Platforms)
- Use Auto Layout for all components.
- Define padding and spacing on every container.
- Specify min and max widths for columns and sidebars.
- Use constraints for safe area and window resize behavior.

## Recommended Layout Constraints
- Mac main layout: left sidebar fixed width 280, main content flexible, right panel optional 320.
- iPhone: single-column scroll with sticky top header.
- iPad: two-column split, primary 60 percent, secondary 40 percent.
- Coding Environment iPad: left list 280, editor area flexible, output panel fixed 280.

## End-To-End Flow Diagram
- FigJam link: https://www.figma.com/online-whiteboard/create-diagram/50980311-5f51-41f1-8025-0aee74095d7b?utm_source=other&utm_content=edit_in_figjam&oai_id=&request_id=2e0f8eab-9c06-4fd3-8a1d-4f15c03b0812

## Execution Plan
1. Foundations and components in Figma.
2. Screen inventory for Mac, iPhone, iPad.
3. Constraints and sizing pass.
4. Prototype flows.
5. Implementation sync with SwiftUI.
6. Phase 2: remote execution for coding environment.
