# FocusApp Variables Import — Figma Plugin

A local Figma plugin that creates all FocusApp design system variables (colors, spacing, radii, sizing) in your Figma file with a single click.

## What It Creates

| Collection | Modes | Variables | Description |
|---|---|---|---|
| **FocusApp Colors** | Light + Dark | 39 | Brand, neutral, semantic, difficulty, and streak colors |
| **FocusApp Spacing** | Default | 9 | Spacing scale from 2 to 64 |
| **FocusApp Radii** | Default | 4 | Corner radius tokens (small, medium, large, pill) |
| **FocusApp Sizing** | Default | 10 | Fixed sizes for layout landmarks (headers, sidebars, rings) |

**Total: 62 variables across 4 collections.**

The Colors collection includes both Light and Dark mode values for semantic tokens (`background`, `surface`, `surface-elevated`, `text-primary`, `text-secondary`, `border`). All other color variables share the same value across both modes.

## How to Use

1. Open a Figma file where you want the variables created.
2. Go to **Plugins > Development > Import plugin from manifest...**
3. Navigate to this folder and select `manifest.json`.
4. Run the plugin from **Plugins > Development > FocusApp Variables Import**.
5. The plugin will create all 62 variables and close with a success message.

## Files

| File | Purpose |
|---|---|
| `manifest.json` | Plugin metadata (name, entry point, editor type) |
| `code.js` | Plugin script that creates all variable collections and variables |
| `README.md` | This file |

## Notes

- Running the plugin multiple times will create duplicate variables. Delete existing collections first if you need to re-run.
- The plugin uses the Figma Plugin API (`figma.variables.createVariable()` and `figma.variables.createVariableCollection()`).
- Color values are converted from hex (#RRGGBB) to Figma's `{r, g, b, a}` format (0-1 range).
- The `addMode()` API requires a Figma Professional plan or higher for multi-mode collections.
