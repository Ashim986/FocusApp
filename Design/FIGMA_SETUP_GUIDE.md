# FocusApp Figma Setup Guide

Pixel-precise instructions for building every screen, component, and foundation in the FocusApp Figma file.

Figma URL: https://www.figma.com/design/294sd4vhQdwEzizccOY4Bn/Focus-App?node-id=0-1

---

## 1. File Setup

### Pages (create in this order)
1. **Cover** — Title card with app name, version, date
2. **Foundations** — Colors, typography, spacing, grids
3. **Components** — All reusable UI components
4. **iPhone Screens** — All iPhone frames (393x852)
5. **iPad Screens** — All iPad frames (834x1194)
6. **Mac Screens** — macOS frames (placeholder for now)
7. **Flows** — Prototype flow documentation
8. **Specs** — Redline / measurement overlays

### Naming Conventions
- Pages: `Cover`, `Foundations`, `Components`, etc.
- Frames: `iPhone / Today`, `iPad / Plan`, `Mac / Focus Overlay`
- Components: `Button / Primary`, `Card / DailyGoal`, `Badge / Difficulty / Easy`
- Styles: `Color / Primary`, `Type / Headline`, `Effect / CardShadow`

---

## 2. Foundations

### 2.1 Color Styles

Create Figma Color Styles for each. Use naming like `Color/Primary`.

#### Brand Colors
| Style Name | Hex | Usage |
|---|---|---|
| Color/Purple | #6366F1 | Primary accent, active tabs, buttons |
| Color/Indigo | #1E1B4B | Dark accents |
| Color/IndigoLight | #312E81 | Dark accent variant |
| Color/Green | #10B981 | Success, Easy badge, completion |
| Color/GreenLight | #D1FAE5 | Easy badge background |
| Color/Cyan | #22D3EE | Secondary accent |
| Color/Amber | #F59E0B | Warning, Medium badge text |
| Color/AmberLight | #FEF3C7 | Medium badge background |
| Color/Red | #EF4444 | Error, Hard badge, Sign Out |
| Color/RedLight | #FEE2E2 | Hard badge bg, Pomodoro timer bg |

#### Neutral Colors
| Style Name | Hex | Usage |
|---|---|---|
| Color/Gray50 | #F9FAFB | Background (light) |
| Color/Gray100 | #F3F4F6 | Surface elevated |
| Color/Gray200 | #E5E7EB | Dividers, borders |
| Color/Gray300 | #D1D5DB | Disabled states |
| Color/Gray400 | #9CA3AF | Inactive tab icons |
| Color/Gray500 | #6B7280 | Secondary text (light) |
| Color/Gray600 | #4B5563 | Body text secondary |
| Color/Gray700 | #374151 | Dark surface elevated |
| Color/Gray800 | #1F2937 | Dark surface, code editor bg |
| Color/Gray900 | #111827 | Dark background, primary text |

#### Gradient Fills
| Style Name | From | To | Usage |
|---|---|---|---|
| Gradient/Purple | #6366F1 | #8B5CF6 | Daily Goal card |
| Gradient/Indigo | #1E1B4B | #312E81 | Dark accents |

#### Semantic Colors (Light Mode)
| Style Name | Hex |
|---|---|
| Semantic/Background | #F9FAFB |
| Semantic/Surface | #FFFFFF |
| Semantic/SurfaceElevated | #F3F4F6 |
| Semantic/TextPrimary | #111827 |
| Semantic/TextSecondary | #4B5563 |
| Semantic/Divider | #E5E7EB |
| Semantic/Accent | #6366F1 |
| Semantic/Success | #10B981 |
| Semantic/Warning | #F59E0B |
| Semantic/Error | #EF4444 |

#### Semantic Colors (Dark Mode)
| Style Name | Hex |
|---|---|
| Semantic/Background | #111827 |
| Semantic/Surface | #1F2937 |
| Semantic/SurfaceElevated | #374151 |
| Semantic/TextPrimary | #F9FAFB |
| Semantic/TextSecondary | #D1D5DB |
| Semantic/Divider | #374151 |
| Semantic/Accent | #6366F1 |
| Semantic/Success | #10B981 |
| Semantic/Warning | #F59E0B |
| Semantic/Error | #EF4444 |

### 2.2 Typography Styles

Font family: **SF Pro** (use Inter as Figma fallback). Code: **SF Mono** (use JetBrains Mono as fallback).

Create Figma Text Styles:

| Style Name | Font | Weight | Size | Line Height |
|---|---|---|---|---|
| Type/Title | SF Pro | Bold | 32 | 40 |
| Type/Headline | SF Pro | Bold | 24 | 32 |
| Type/Section | SF Pro | Semibold | 20 | 28 |
| Type/Body | SF Pro | Regular | 16 | 24 |
| Type/BodyStrong | SF Pro | Semibold | 16 | 24 |
| Type/Subbody | SF Pro | Regular | 14 | 20 |
| Type/SubbodyStrong | SF Pro | Semibold | 14 | 20 |
| Type/Caption | SF Pro | Regular | 12 | 16 |
| Type/CaptionStrong | SF Pro | Semibold | 12 | 16 |
| Type/Micro | SF Pro | Regular | 11 | 14 |
| Type/MicroStrong | SF Pro | Semibold | 11 | 14 |
| Type/Code | SF Mono | Regular | 12 | 16 |
| Type/CodeMicro | SF Mono | Regular | 11 | 14 |
| Type/TimerLarge | SF Pro | Bold | 64 | 72 |

### 2.3 Spacing Scale

| Token | Value | Usage |
|---|---|---|
| space-2 | 2px | Hairline gaps |
| space-4 | 4px | Tight padding, icon-to-text gap |
| space-8 | 8px | Standard inner padding |
| space-12 | 12px | Card gap, list item spacing |
| space-16 | 16px | Screen horizontal padding, card padding |
| space-24 | 24px | Section spacing |
| space-32 | 32px | Large section gaps |
| space-48 | 48px | Screen section dividers |
| space-64 | 64px | Top padding below header |

### 2.4 Corner Radius Tokens

| Token | Value | Usage |
|---|---|---|
| radius-8 | 8px | Small chips, badges |
| radius-12 | 12px | Cards, buttons |
| radius-16 | 16px | Large cards, timer card |
| radius-full | 9999px | Pills, circular buttons, avatar |

### 2.5 Shadow Tokens

| Style Name | Values | Usage |
|---|---|---|
| Effect/CardShadow | X:0, Y:1, Blur:3, Spread:0, Color:#0000000D (5% black) | Cards |
| Effect/ElevatedShadow | X:0, Y:4, Blur:12, Spread:0, Color:#0000001A (10% black) | Elevated cards, modals |

### 2.6 Grid Definitions

**iPhone frame (393x852)**
- Layout grid: 1 column, 16px margin left+right, 361px content width
- Row grid: 4px spacing

**iPad frame (834x1194)**
- Layout grid: Sidebar 260px fixed left + content area 574px
- Content grid: 16px margin, flexible columns
- Row grid: 8px spacing

**Mac frame (1200x760)**
- Layout grid: 280px sidebar + flexible content + optional 320px right panel
- Row grid: 8px spacing

---

## 3. Components

Build each as a Figma Component (main component on the Components page). Use Auto Layout where specified.

### 3.1 Bottom Tab Bar (iPhone)

**Dimensions**: 393 x 83 (includes 34px safe area at bottom)
**Background**: Semantic/Surface (#FFFFFF), top border 0.5px Semantic/Divider

**Auto Layout**: Horizontal, space-between, 0px gap
**Padding**: 8px top, 34px bottom (safe area), 0px sides

**Tab Item** (5 items, each ~78px wide):
- Auto Layout: Vertical, center-aligned, 4px gap
- Icon: 24x24, stroke 1.5px
- Label: Type/Micro (11px), center-aligned

**States**:
| State | Icon Color | Label Color |
|---|---|---|
| Inactive | Color/Gray400 (#9CA3AF) | Color/Gray400 |
| Active | Color/Purple (#6366F1) | Color/Purple |

**Tab items (left to right)**:
1. Home icon + "Today"
2. Calendar icon + "Plan"
3. Bar-chart icon + "Stats"
4. Lightning-bolt icon + "Focus"
5. Code-brackets icon + "Coding"

### 3.2 Sidebar Navigation (iPad)

**Dimensions**: 260 x full height (1194)
**Background**: Semantic/Surface (#FFFFFF)
**Right border**: 1px Semantic/Divider

**Structure** (Auto Layout: Vertical, space-between):
- Top section:
  - Logo/title: "FocusApp" — Type/Section (20/Semibold), 24px left padding, 24px top padding
  - 24px spacer
  - Nav items (Auto Layout: Vertical, 4px gap, 12px horizontal padding)
- Bottom section:
  - User profile row, 16px padding

**Nav Item**:
- Dimensions: 236 x 44
- Auto Layout: Horizontal, 12px gap, 12px horizontal padding, center-vertically
- Icon: 20x20
- Label: Type/Body (16/Regular)
- Corner radius: radius-8 (8px)

**Nav Item States**:
| State | Background | Icon Color | Label Color |
|---|---|---|---|
| Default | Transparent | Color/Gray500 | Color/Gray700 |
| Active | Color/Purple at 10% (#6366F11A) | Color/Purple | Color/Purple |
| Hover | Color/Gray100 | Color/Gray500 | Color/Gray700 |

**Nav items (top to bottom)**:
1. Home icon + "Today"
2. Calendar icon + "Plan"
3. Chart icon + "Stats"
4. Lightning icon + "Focus"
5. Code icon + "Coding"
6. Gear icon + "Settings"

**User Profile** (bottom):
- Auto Layout: Horizontal, 12px gap, 16px padding
- Avatar: 36x36 circle, Color/Purple background, white initials "JD" (Type/SubbodyStrong)
- Name: "John Doe" — Type/SubbodyStrong, Color/Gray900
- Plan: "Pro Plan" — Type/Caption, Color/Gray500

### 3.3 Header Bar (iPhone)

**Dimensions**: 393 x 44 (below status bar)
**Background**: Semantic/Background
**Auto Layout**: Horizontal, space-between, 16px horizontal padding, center-vertically

- Title: "FocusApp" — Type/BodyStrong (16/Semibold), center
- Settings icon: 24x24 gear icon, Color/Gray600, right side

### 3.4 Card / Surface

**Dimensions**: variable width x auto height
**Background**: Semantic/Surface (#FFFFFF)
**Border**: 1px, Semantic/Divider (#E5E7EB)
**Corner radius**: radius-12 (12px)
**Shadow**: Effect/CardShadow
**Padding**: 16px all sides

### 3.5 Daily Goal Card

**Dimensions**: 361 x 140 (full content width on iPhone)
**Background**: Gradient/Purple (#6366F1 to #8B5CF6), top-left to bottom-right
**Corner radius**: radius-16 (16px)
**Padding**: 20px all sides

**Contents** (Auto Layout: Vertical, 12px gap):
- Row 1 (Horizontal, space-between):
  - Target icon: 24x24, white, circle bg white at 20%
  - "Daily Goal" — Type/SubbodyStrong, white
- Row 2:
  - "1/4" — Type/Title (32/Bold), white
  - "Tasks completed" — Type/Subbody (14/Regular), white at 80%
- Row 3:
  - Progress bar: full width, 6px height, radius-full
  - Track: white at 30%
  - Fill: white, width = (completed/total) * 100%

### 3.6 Focus Time Card

**Dimensions**: 361 x 100 (full content width)
**Background**: Semantic/Surface
**Border**: 1px Semantic/Divider
**Corner radius**: radius-12
**Padding**: 16px

**Contents** (Auto Layout: Horizontal, 12px gap):
- Left: Pulse icon (24x24) in a 40x40 circle, background Color/GreenLight (#D1FAE5), icon Color/Green
- Right (Auto Layout: Vertical, 4px gap):
  - Top row: "Focus Time" — Type/SubbodyStrong, Color/Gray500, right-aligned
  - Value: "2h 15m" — Type/Headline (24/Bold), Color/Gray900
  - Subtitle: "35m remaining today" — Type/Caption, Color/Gray500

### 3.7 Start Focus CTA Card

**Dimensions**: 361 x 88
**Background**: Semantic/Surface
**Border**: 1px Semantic/Divider (dashed, 4px dash)
**Corner radius**: radius-12
**Padding**: 16px

**Contents** (Auto Layout: Vertical, center, 8px gap):
- Arrow icon: 24x24, Color/Purple, inside 40x40 circle with Color/Purple at 10% bg
- Title: "Start Focus Session" — Type/BodyStrong, Color/Gray900
- Subtitle: "Ready to get in the zone?" — Type/Caption, Color/Gray500

### 3.8 Task Row

**Dimensions**: 361 x 56
**Auto Layout**: Horizontal, center-vertically, 12px gap, 16px horizontal padding

- Check icon: 24x24
  - Completed: filled circle, Color/Purple, white check inside
  - Pending: dashed circle, Color/Gray300, 1.5px stroke
- Title area (Auto Layout: Vertical, 2px gap, fill width):
  - Title: Type/BodyStrong — Color/Gray900 (or strikethrough + Color/Gray400 if completed)
  - Subtitle: Type/Caption — Color/Gray500 (e.g. "Arrays & Hashing - LeetCode 75")
- Badge slot: Difficulty Badge component (optional)
- Chevron: 16x16, Color/Gray400

**Variants**: default, completed (strikethrough), habit (with fraction like "1/4")

### 3.9 Difficulty Badge

**Auto Layout**: Horizontal, 8px horizontal padding, 4px vertical padding
**Corner radius**: radius-8
**Text**: Type/CaptionStrong

| Variant | Background | Text Color |
|---|---|---|
| Easy | #D1FAE5 | #059669 |
| Medium | #FEF3C7 | #D97706 |
| Hard | #FEE2E2 | #DC2626 |

### 3.10 Streak Badge

**Auto Layout**: Horizontal, 12px horizontal padding, 8px vertical padding, 4px gap
**Background**: #FFF7ED (orange-50)
**Corner radius**: radius-full
**Border**: 1px #FDBA74 (orange-300)

- Fire emoji/icon: 16x16
- Text: "12 Day Streak" — Type/SubbodyStrong, #EA580C (orange-600)

### 3.11 Metric Card

**Dimensions**: variable (2-up grid on iPhone = ~170x80 each, 4-up row on iPad)
**Background**: Semantic/Surface
**Border**: 1px Semantic/Divider
**Corner radius**: radius-12
**Padding**: 16px
**Auto Layout**: Vertical, center, 4px gap

- Label: Type/Caption, Color/Gray500 (e.g. "Total Focus")
- Value: Type/Headline (24/Bold), Color/Gray900 (e.g. "34h 12m")

### 3.12 Pomodoro Segmented Control

**Dimensions**: 329 x 44 (full card width minus padding)
**Background**: Color/Gray100 (#F3F4F6)
**Corner radius**: radius-full
**Padding**: 4px

**Segments** (3 equal-width items):
- Each segment: ~107 x 36
- Auto Layout: Horizontal, center, 6px gap
- Icon: 16x16
- Label: Type/SubbodyStrong

| Segment | Icon | Label |
|---|---|---|
| Focus | Crosshair | "Focus" |
| Short Break | Coffee cup | "Short Break" |
| Long Break | Moon | "Long Break" |

**Selected state**:
- Background: Semantic/Surface (white), radius-full
- Shadow: Effect/CardShadow
- Text: Color/Gray900

**Unselected state**:
- Background: transparent
- Text: Color/Gray500

### 3.13 Timer Ring

**Dimensions**: 280 x 280 (iPhone), 400 x 400 (iPad)
**Structure**:
- Track circle: stroke 8px, Color/Gray200
- Progress arc: stroke 8px, Color/Red (#EF4444) for Focus, Color/Purple for iPad variant
- Dot indicator: 12x12 circle, same color as progress, at current progress angle (12 o'clock = 0%)
- Center text: "25:00" — Type/TimerLarge (64/Bold), Color/Gray900
- Status label: "PAUSED" or "RUNNING" — Type/CaptionStrong, Color/Gray400, letter-spacing 2px

### 3.14 Start / Pause Button

**Dimensions**: auto width x 48, min-width 120
**Background**: Color/Red (#EF4444)
**Corner radius**: radius-12
**Padding**: 16px horizontal, 12px vertical
**Auto Layout**: Horizontal, center, 8px gap

- Icon: 20x20 play/pause, white
- Label: "Start" or "Pause" — Type/BodyStrong, white

### 3.15 Reset Button

**Dimensions**: 48 x 48
**Background**: Semantic/Surface
**Border**: 1px Semantic/Divider
**Corner radius**: radius-12

- Icon: 20x20 reset/undo arrow, Color/Gray500, centered

### 3.16 Calendar Grid

**Dimensions**: 361 x auto (fits within card)

**Header** (Auto Layout: Horizontal, space-between, center-vertically):
- Month/Year: "February 2026" — Type/Section (20/Semibold)
- Left arrow: 24x24, Color/Gray500
- Right arrow: 24x24, Color/Gray500

**Weekday labels** (Auto Layout: Horizontal, 7 equal columns, ~50px each):
- "SU", "MO", "TU", "WE", "TH", "FR", "SA" — Type/CaptionStrong, Color/Gray400

**Date grid** (7 columns x 5 rows):
- Each cell: 50 x 44, center-aligned
- Date text: Type/Body (16/Regular)

**Date cell states**:
| State | Background | Text Color |
|---|---|---|
| Default | Transparent | Color/Gray900 |
| Today/Selected | Color/Purple circle (36x36) | White |
| Has events | Small dot (4px) below date, Color/Purple | Color/Gray900 |
| Other month | Transparent | Color/Gray300 |

**Selected date label** (below grid):
- "You selected Feb 7, 2026." — Type/Subbody, Color/Gray500, center-aligned

### 3.17 Schedule Row

**Dimensions**: full width x 72
**Auto Layout**: Horizontal, 16px gap, 16px padding, center-vertically
**Corner radius**: radius-12

- Time label: 60px width — Type/SubbodyStrong, Color/Purple (active) or Color/Gray500 (normal)
- Content area (Auto Layout: Vertical, 2px gap):
  - Title: Type/BodyStrong, Color/Gray900
  - Subtitle: Type/Caption, Color/Gray500

**Variants**:
| State | Background | Time Color | Opacity |
|---|---|---|---|
| Active | Color/Purple at 8% (#6366F114) | Color/Purple | 100% |
| Normal | Transparent | Color/Gray500 | 100% |
| Past/Faded | Transparent | Color/Gray400 | 50% |

### 3.18 Bar Chart

**Dimensions**: 361 x 240 (within card)
**Background**: Semantic/Surface

- Y-axis labels: Type/Caption, Color/Gray400, left-aligned (0, 2, 4, 6, 8)
- X-axis labels: Type/Caption, Color/Gray400, center below bars (Mon, Tue, Wed, Thu, Fri, Sat, Sun)
- Grid lines: 0.5px dashed, Color/Gray200
- Bars: 32px wide, radius-8 top corners, Color/Purple
- Bar gap: 16px between bars

### 3.19 Line Chart

**Dimensions**: 361 x 240 (within card)
**Background**: Semantic/Surface

- Y-axis labels: Type/Caption, Color/Gray400 (0, 3, 6, 9, 12)
- X-axis labels: same as bar chart
- Grid lines: 0.5px dashed, Color/Gray200
- Line: 2px stroke, Color/Green (#10B981)
- Dot markers: 8x8 circle, Color/Green, at each data point

### 3.20 Problem Card

**Dimensions**: 361 x 72
**Background**: Semantic/Surface
**Border**: 1px Semantic/Divider
**Corner radius**: radius-12
**Padding**: 16px
**Auto Layout**: Horizontal, space-between, center-vertically

- Left (Auto Layout: Vertical, 4px gap):
  - Title: Type/BodyStrong, Color/Gray900
  - Difficulty Badge component
- Right:
  - Solved: 24x24 circle, Color/Green, white check
  - Unsolved: 24x24 circle, 1.5px stroke Color/Gray300

### 3.21 Problem Detail Tabs

**Dimensions**: full width x 44
**Auto Layout**: Horizontal, 0 gap
**Bottom border**: 1px Semantic/Divider

**Tab item**: auto width, 16px horizontal padding, 44px height, center-aligned
- Label: Type/SubbodyStrong

| State | Text Color | Bottom border |
|---|---|---|
| Active | Color/Purple | 2px Color/Purple |
| Inactive | Color/Gray500 | None |

**Tabs**: "Desc", "Solution", "Code"

### 3.22 Code Viewer

**Dimensions**: full width x auto
**Background**: Color/Gray800 (#1F2937)
**Corner radius**: radius-12 (top) or 0 (when full-width)
**Padding**: 16px

**Header** (Auto Layout: Horizontal, space-between):
- Language label: "TypeScript" — Type/CaptionStrong, Color/Gray400
- Lock icon + "Read-only" — Type/Caption, Color/Gray400, 4px gap

**Code area**:
- Line numbers: Type/CodeMicro, Color/Gray500, right-aligned, 32px width
- Code text: Type/Code, Color/Gray300 (default)
- Syntax colors:
  - Keywords: #C084FC (purple-400)
  - Types: #67E8F9 (cyan-300)
  - Functions: #FCD34D (amber-300)
  - Strings: #86EFAC (green-300)
  - Numbers: #FCA5A5 (red-300)
  - Comments: #6B7280 (gray-500)

### 3.23 Settings Row

**Dimensions**: full width x 56
**Auto Layout**: Horizontal, 12px gap, 16px padding, center-vertically

- Icon: 20x20, inside 36x36 circle, Color/Gray100 background, Color/Gray600 icon
- Content (Auto Layout: Vertical, 2px gap, fill):
  - Title: Type/BodyStrong, Color/Gray900
  - Subtitle: Type/Caption, Color/Gray500
- Chevron: 16x16, Color/Gray400

### 3.24 Search Bar

**Dimensions**: 361 x 44
**Background**: Color/Gray100 (#F3F4F6)
**Corner radius**: radius-12
**Padding**: 12px horizontal
**Auto Layout**: Horizontal, 8px gap, center-vertically

- Search icon: 20x20, Color/Gray400
- Placeholder: "Search problems..." — Type/Body, Color/Gray400

### 3.25 Sign Out Button

**Dimensions**: 361 x 48
**Background**: Color/RedLight (#FEE2E2)
**Corner radius**: radius-12
**Auto Layout**: Horizontal, center, 8px gap

- Icon: 20x20, Color/Red
- Label: "Sign Out" — Type/BodyStrong, Color/Red

### 3.26 Floating Help Button (iPad)

**Dimensions**: 48 x 48
**Background**: Color/Gray800
**Corner radius**: radius-full (circle)
**Shadow**: Effect/ElevatedShadow

- Icon: "?" — Type/BodyStrong, white, centered
- Position: 24px from bottom-right of content area

---

## 4. iPhone Screens (393 x 852)

Each frame is 393x852. Status bar is 47px from top (use Figma iPhone status bar component or leave space). Bottom tab bar is 83px at bottom. Content area: 47px top to 769px (722px available).

Screen horizontal padding: 16px each side (content width = 361px).

### 4.1 iPhone Today

**Frame**: "iPhone / Today" — 393 x 852

| Element | Y Position | Component | Notes |
|---|---|---|---|
| Status bar | 0 | (system) | 47px height |
| Header bar | 47 | Header Bar | "FocusApp" + gear |
| Date label | 107 | Text | "FRIDAY, FEBRUARY 6" — Type/CaptionStrong, Color/Gray500, uppercase, 16px left |
| Greeting | 127 | Text | "Good Morning, John" — Type/Title (32/Bold), 16px left |
| Streak badge | 171 | Streak Badge | 16px left |
| Daily Goal card | 207 | Daily Goal Card | 16px margins, 361px wide |
| Focus Time card | 359 | Focus Time Card | 12px gap below goal card |
| Start Focus CTA | 471 | Start Focus CTA Card | 12px gap |
| "Today's Plan" header | 575 | Text row | "Today's Plan" (Type/Section) left + "View Full Plan" (Type/Subbody, Color/Purple) right |
| Task row 1 | 611 | Task Row (completed) | "Complete Two Sum" + Easy badge, strikethrough |
| Task row 2 | 667 | Task Row (completed) | "Read System Design Chapter 5" |
| Task row 3 | 723 | Task Row (completed) | "Review Pull Requests" |
| Tab bar | 769 | Bottom Tab Bar | "Today" active |

**Scroll behavior**: Content below "Start Focus CTA" scrolls under sticky header. Create a second frame "iPhone / Today (Scrolled)" showing the plan list visible.

### 4.2 iPhone Today (Scrolled)

**Frame**: "iPhone / Today (Scrolled)" — 393 x 852

Same header + tab bar. Content shows bottom portion:
- Focus Time card (partially visible at top)
- Start Focus CTA
- "Today's Plan" header + "View Full Plan"
- Task rows (4 items with varying states)
- Tab bar (Today active)

### 4.3 iPhone Plan

**Frame**: "iPhone / Plan" — 393 x 852

| Element | Y Position | Component | Notes |
|---|---|---|---|
| Header bar | 47 | Header Bar | |
| "Study Plan" title | 99 | Text | Type/Headline, 16px left |
| Calendar card | 139 | Card containing Calendar Grid | 16px margins, auto height (~340px) |
| Schedule section title | 499 | Text | "Schedule for February 7th" — Type/Section, 16px left |
| Schedule row 1 (active) | 539 | Schedule Row (active) | "09:00 AM" + "Morning Review" |
| Schedule row 2 | 611 | Schedule Row (normal) | "10:30 AM" + "Graph Theory" |
| Schedule row 3 | 683 | Schedule Row (faded) | "02:00 PM" + "Mock Interview" (partially visible) |
| Tab bar | 769 | Bottom Tab Bar | "Plan" active |

### 4.4 iPhone Stats

**Frame**: "iPhone / Stats" — 393 x 852

| Element | Y Position | Component | Notes |
|---|---|---|---|
| Header bar | 47 | Header Bar | |
| "Your Statistics" title | 99 | Text | Type/Headline, 16px left |
| Weekly Focus Time card | 139 | Card + Bar Chart | 361 x 280 |
| Problems Solved card | 431 | Card + Line Chart | 361 x 280 |
| Metric cards (2x2) | 723 | 4 x Metric Card | 2 columns, 8px gap. Top: "Total Focus" + "Current Streak". Bottom: "Problems Solved" + "Avg. Difficulty" |
| Tab bar | 769 | Bottom Tab Bar | "Stats" active |

**Note**: Stats page scrolls. Second row of metric cards is below fold.

### 4.5 iPhone Stats (Scrolled)

**Frame**: "iPhone / Stats (Scrolled)" — 393 x 852

Shows bottom of Problems Solved chart + all 4 metric cards visible:
- Total Focus: "34h 12m"
- Current Streak: "12 Days"
- Problems Solved: "45"
- Avg. Difficulty: "Medium"

### 4.6 iPhone Focus (Paused)

**Frame**: "iPhone / Focus (Paused)" — 393 x 852

| Element | Y Position | Component | Notes |
|---|---|---|---|
| "Focus" title | 55 | Text | Type/Section (20/Semibold), 16px left |
| "Sessions: 0" badge | 55 | Badge | right side, 16px right. Pill: Color/Gray100 bg, Type/SubbodyStrong |
| Timer card | 99 | Card | 361 x 420, Color/RedLight bg (#FEE2E2), radius-16 |
| - Segmented control | 119 | Pomodoro Segmented | Inside card, 16px from top |
| - Timer ring | 179 | Timer Ring (280x280) | Centered in card |
| - "25:00" | center | Text | Inside ring, Type/TimerLarge |
| - "PAUSED" | below time | Text | Type/CaptionStrong, Color/Gray400 |
| - Start button | 475 | Start Button | Centered, red |
| - Reset button | 475 | Reset Button | Right of start, 12px gap |
| "CURRENT FOCUS" label | 539 | Text | Type/CaptionStrong, Color/Gray400, uppercase, center |
| "No active tasks" | 559 | Text | Type/Subbody, Color/Gray400, italic, center |
| Tasks card | 599 | Card | "Tasks 0" header + empty list |
| Tab bar | 769 | Bottom Tab Bar | "Focus" active |

### 4.7 iPhone Focus (Running)

**Frame**: "iPhone / Focus (Running)" — 393 x 852

Same as paused but:
- Timer shows "24:54" with ring partially filled
- Status: "RUNNING"
- Button: "Pause" (red) instead of "Start"
- Ring progress arc visible (small amount filled)

### 4.8 iPhone Coding - Problem List

**Frame**: "iPhone / Coding - List" — 393 x 852

| Element | Y Position | Component | Notes |
|---|---|---|---|
| Header bar | 47 | Header Bar | |
| Search bar | 99 | Search Bar | 16px margins |
| Problem card 1 | 155 | Problem Card | "Two Sum" + Easy + solved check |
| Problem card 2 | 239 | Problem Card | "Add Two Numbers" + Medium + unsolved |
| Problem card 3 | 323 | Problem Card | "Longest Substring" + Medium + unsolved |
| Problem card 4 | 407 | Problem Card | "Median of Two Sorted Arrays" + Hard + unsolved |
| Tab bar | 769 | Bottom Tab Bar | "Coding" active |

Card gap: 12px between problem cards.

### 4.9 iPhone Coding - Problem Detail (Desc)

**Frame**: "iPhone / Coding - Detail (Desc)" — 393 x 852

| Element | Y Position | Component | Notes |
|---|---|---|---|
| Header bar | 47 | Header Bar | |
| Back row | 91 | Horizontal | Chevron left (24x24) + "Two Sum" — Type/Section, 16px left |
| Detail tabs | 131 | Problem Detail Tabs | Desc (active), Solution, Code |
| Problem title | 187 | Text | "Two Sum" — Type/Section, 16px left |
| Difficulty badge | 219 | Difficulty Badge | Easy |
| Description | 251 | Text block | Type/Body, Color/Gray700, 16px margins, multi-line |
| Tab bar | 769 | Bottom Tab Bar | "Coding" active |

### 4.10 iPhone Coding - Problem Detail (Solution)

**Frame**: "iPhone / Coding - Detail (Solution)" — 393 x 852

Same header, back row, tabs (Solution active).
- Content area: "Solution content would go here..." — Type/Body, Color/Gray400, italic

### 4.11 iPhone Coding - Problem Detail (Code)

**Frame**: "iPhone / Coding - Detail (Code)" — 393 x 852

Same header, back row, tabs (Code active).
- Code Viewer component: full width below tabs, dark bg, syntax highlighted code
- Header inside viewer: "TypeScript" + lock icon + "Read-only"
- Sample code: Two Sum solution with line numbers

### 4.12 iPhone Settings

**Frame**: "iPhone / Settings" — 393 x 852

| Element | Y Position | Component | Notes |
|---|---|---|---|
| Header bar | 47 | Header Bar | |
| "Settings" title | 99 | Text | Type/Headline, 16px left |
| "ACCOUNT" section | 147 | Text | Type/CaptionStrong, Color/Gray500, uppercase |
| Card (Account) | 171 | Card | Contains 2 Settings Rows |
| - Profile row | 171 | Settings Row | Person icon + "Profile" / "John Doe" |
| - Divider | 227 | Line | 1px Semantic/Divider, 16px left indent |
| - Security row | 228 | Settings Row | Shield icon + "Security" / "Password, 2FA" |
| "PREFERENCES" section | 308 | Text | Type/CaptionStrong, Color/Gray500, uppercase |
| Card (Preferences) | 332 | Card | Contains 2 Settings Rows |
| - Notifications row | 332 | Settings Row | Bell icon + "Notifications" / "On" |
| - Divider | 388 | Line | |
| - Appearance row | 389 | Settings Row | Moon icon + "Appearance" / "Light" |
| Sign Out button | 477 | Sign Out Button | 16px margins |
| Tab bar | 769 | Bottom Tab Bar | No tab active (settings is a push) |

---

## 5. iPad Screens (834 x 1194)

All iPad screens: 834 x 1194 frame. Sidebar: 260px left. Content area: 574px right. No bottom tab bar.

### 5.1 iPad Today

**Frame**: "iPad / Today" — 834 x 1194

**Sidebar** (0, 0, 260, 1194): Sidebar Navigation component, "Today" active.

**Content area** (260, 0, 574, 1194):
| Element | Position (relative to content) | Notes |
|---|---|---|
| Date + greeting | x:24, y:24 | "SATURDAY, FEBRUARY 7" + "Good Morning, John" |
| Streak badge | x:24, y:80 | Right-aligned, same row as greeting |
| Card strip (3 cards) | x:24, y:108, gap:12 | Horizontal: Daily Goal (~176w) + Focus Time (~176w) + Start CTA (~176w) |
| "Today's Plan" + "View Full Plan" | x:24, y:264 | Horizontal, space-between |
| Task row 1 | x:24, y:300 | Full content width |
| Task row 2 | x:24, y:356 | |
| Task row 3 | x:24, y:412 | |
| Task row 4 | x:24, y:468 | |

**Floating help button**: x:786, y:1122 (bottom-right of content area, 24px inset)

### 5.2 iPad Plan

**Frame**: "iPad / Plan" — 834 x 1194

**Sidebar**: "Plan" active.

**Content area** (574px wide, split into two columns):
| Element | Position | Dimensions |
|---|---|---|
| "Study Plan" title | x:284, y:24 | Type/Headline |
| Calendar card | x:284, y:68 | 267 x 380 (left column, ~48% width) |
| Schedule section | x:563, y:68 | 247 x 380 (right column, ~48% width) |
| "Schedule for Feb 7th" | top of right column | Type/Section |
| Schedule row 1 (active) | y:108 in right col | "09:00 AM" + "Morning Review" |
| Schedule row 2 | y:180 | "10:30 AM" + "Graph Theory" |
| Schedule row 3 (faded) | y:252 | "02:00 PM" + "Mock Interview" |

Gap between columns: 12px.

### 5.3 iPad Stats

**Frame**: "iPad / Stats" — 834 x 1194

**Sidebar**: "Stats" active.

**Content area**:
| Element | Position | Dimensions |
|---|---|---|
| "Your Statistics" title | x:284, y:24 | Type/Headline |
| Weekly Focus chart card | x:284, y:68 | 267 x 300 (left) |
| Problems Solved chart card | x:563, y:68 | 247 x 300 (right) |
| Metric card 1: Total Focus | x:284, y:380 | ~130 x 80 |
| Metric card 2: Current Streak | x:420, y:380 | ~130 x 80 |
| Metric card 3: Problems Solved | x:556, y:380 | ~130 x 80 |
| Metric card 4: Avg. Difficulty | x:692, y:380 | ~130 x 80 |

4 metric cards in a single row, 8px gaps.

### 5.4 iPad Focus

**Frame**: "iPad / Focus" — 834 x 1194

**Sidebar**: "Focus" active.

**Content area** (centered):
| Element | Position | Notes |
|---|---|---|
| "Deep Work Session" | center, y:80 | Type/Headline, center-aligned |
| Subtitle | center, y:116 | "Stay focused and track your progress." — Type/Subbody, Color/Gray500 |
| Timer ring | center, y:180 | 400 x 400, Color/Purple ring |
| "25:00" | center of ring | Type/TimerLarge |
| Play button | center, y:620 | 56x56 circle, Color/Purple, white play icon |
| Reset button | 12px right of play | 48x48, gray surface |
| Sessions stat | center-left, y:700 | "3" — Type/Headline + "SESSIONS" — Type/CaptionStrong |
| Total Focus stat | center-right, y:700 | "75m" — Type/Headline + "TOTAL FOCUS" — Type/CaptionStrong |

### 5.5 iPad Coding Environment

**Frame**: "iPad / Coding" — 834 x 1194

**Sidebar**: "Coding" active.

**Content** is a 3-panel layout:

| Panel | X | Width | Content |
|---|---|---|---|
| Problem list | 260 | 220 | "Coding Environment" header + search bar + problem cards |
| Center | 481 | 213 | "Select a problem" placeholder (or problem description) |
| Right | 694 | 140 | "OUTPUT / TEST CASES" header + test case display |

**Top-right**: "Run" button — 80 x 36, Color/Purple, white play icon + "Run" text

**Problem list panel**:
- Header: "Coding Environment" — Type/BodyStrong, 12px padding
- Search bar: full panel width, 12px margins
- Problem items: title + difficulty (Type/Caption) + check icon

**Center panel** (no problem selected):
- "Select a problem" — Type/Body, Color/Gray400, centered

**Right panel**:
- "OUTPUT / TEST CASES" — Type/CaptionStrong, uppercase
- "Case 1" — Type/SubbodyStrong
- Input block: dark bg snippet showing test input
- "Output: [0,1]" — Type/Code
- "Console" section: "No output yet..." — Type/Code, Color/Gray400

**Bottom section** (below center panel):
- "DESCRIPTION" — Type/CaptionStrong, uppercase
- "No problem selected." — Type/Body, Color/Gray400

### 5.6 iPad Settings

**Frame**: "iPad / Settings" — 834 x 1194

**Sidebar**: "Settings" active.

**Content** (centered, max 500px width within 574px area):
- Same structure as iPhone Settings but wider rows
- "Settings" — Type/Headline, left
- Account card, Preferences card, Sign Out button
- All positioned starting at x:284 + center offset

---

## 6. Prototype Flows

### Flow 1: Today to Focus
1. iPhone Today > tap "Start Focus Session" CTA > navigates to iPhone Focus (Paused)
2. Tap "Start" > swap to iPhone Focus (Running)
3. Timer completes > swap to Short Break variant (future frame)

### Flow 2: Coding Navigation
1. iPhone Coding List > tap "Two Sum" row > push to Problem Detail (Desc)
2. Tap "Solution" tab > swap to (Solution)
3. Tap "Code" tab > swap to (Code)
4. Tap back chevron > pop to Coding List

### Flow 3: Focus Timer States
1. Focus (Paused) > tap Start > Focus (Running)
2. Focus (Running) > tap Pause > Focus (Paused)
3. Focus (Running) > tap Reset > Focus (Paused, timer reset to 25:00)

### Flow 4: Tab Navigation
1. Any screen > tap tab bar item > navigate to corresponding screen
2. Active tab updates accent color

### Flow 5: Settings
1. Any screen > tap gear icon > push Settings
2. Tap Profile row > push Profile detail (future frame)
3. Tap Appearance row > push Appearance picker (future frame)

---

## 7. Quick Reference Cheat Sheet

### Frame Sizes
| Device | Width | Height |
|---|---|---|
| iPhone 15 | 393 | 852 |
| iPad 11" | 834 | 1194 |
| Mac window | 1200 | 760 |
| Mac widget | 350 | 560 |

### Key Measurements (iPhone)
| Element | Value |
|---|---|
| Status bar height | 47px |
| Header bar height | 44px |
| Tab bar height | 83px (49 content + 34 safe area) |
| Content start Y | 91px (status + header) |
| Content end Y | 769px (above tab bar) |
| Available content height | 678px |
| Horizontal padding | 16px each side |
| Content width | 361px |
| Card gap | 12px |
| Section gap | 24px |

### Key Measurements (iPad)
| Element | Value |
|---|---|
| Sidebar width | 260px |
| Content start X | 260px |
| Content width | 574px |
| Content padding | 24px |
| Usable content width | 526px |
| Two-column split | ~257px each + 12px gap |
