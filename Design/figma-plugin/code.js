// FocusApp Variables Import — Figma Plugin
// Creates all FocusApp design system variables (colors, spacing, radii, sizing)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Convert a hex string like "#6366F1" to Figma RGBA {r, g, b, a} (0-1 range). */
function hexToRGBA(hex) {
  const h = hex.replace("#", "");
  return {
    r: parseInt(h.substring(0, 2), 16) / 255,
    g: parseInt(h.substring(2, 4), 16) / 255,
    b: parseInt(h.substring(4, 6), 16) / 255,
    a: 1,
  };
}

/**
 * Create a color variable inside a collection and set its value for one or two modes.
 * @param {VariableCollection} collection
 * @param {string} name          — e.g. "brand/purple"
 * @param {string} lightModeId
 * @param {string} darkModeId
 * @param {string} lightHex      — e.g. "#6366F1"
 * @param {string} [darkHex]     — defaults to lightHex when omitted
 */
function createColorVar(collection, name, lightModeId, darkModeId, lightHex, darkHex) {
  const v = figma.variables.createVariable(name, collection, "COLOR");
  v.setValueForMode(lightModeId, hexToRGBA(lightHex));
  v.setValueForMode(darkModeId, hexToRGBA(darkHex || lightHex));
  return v;
}

/**
 * Create a float variable inside a collection and set its value for the default mode.
 * @param {VariableCollection} collection
 * @param {string} name
 * @param {string} modeId
 * @param {number} value
 */
function createFloatVar(collection, name, modeId, value) {
  const v = figma.variables.createVariable(name, collection, "FLOAT");
  v.setValueForMode(modeId, value);
  return v;
}

// ---------------------------------------------------------------------------
// 1. FocusApp Colors  (Light + Dark modes)
// ---------------------------------------------------------------------------

const colorsCollection = figma.variables.createVariableCollection("FocusApp Colors");
const defaultColorModeId = colorsCollection.modes[0].modeId;
colorsCollection.renameMode(defaultColorModeId, "Light");
const darkModeId = colorsCollection.addMode("Dark");
const lightModeId = defaultColorModeId;

// --- Colors where Light === Dark -------------------------------------------

const sharedColors = [
  ["brand/purple",        "#6366F1"],
  ["brand/indigo",        "#1E1B4B"],
  ["brand/indigo-light",  "#312E81"],
  ["brand/green",         "#10B981"],
  ["brand/green-light",   "#D1FAE5"],
  ["brand/cyan",          "#22D3EE"],
  ["brand/amber",         "#F59E0B"],
  ["brand/amber-light",   "#FEF3C7"],
  ["brand/red",           "#EF4444"],
  ["brand/red-light",     "#FEE2E2"],
  ["neutral/gray-50",     "#F9FAFB"],
  ["neutral/gray-100",    "#F3F4F6"],
  ["neutral/gray-200",    "#E5E7EB"],
  ["neutral/gray-300",    "#D1D5DB"],
  ["neutral/gray-400",    "#9CA3AF"],
  ["neutral/gray-500",    "#6B7280"],
  ["neutral/gray-600",    "#4B5563"],
  ["neutral/gray-700",    "#374151"],
  ["neutral/gray-800",    "#1F2937"],
  ["neutral/gray-900",    "#111827"],
  ["semantic/accent",     "#6366F1"],
  ["semantic/success",    "#10B981"],
  ["semantic/warning",    "#F59E0B"],
  ["semantic/danger",     "#EF4444"],
  ["difficulty/easy-bg",      "#D1FAE5"],
  ["difficulty/easy-text",    "#059669"],
  ["difficulty/medium-bg",    "#FEF3C7"],
  ["difficulty/medium-text",  "#D97706"],
  ["difficulty/hard-bg",      "#FEE2E2"],
  ["difficulty/hard-text",    "#DC2626"],
  ["streak/background",  "#FFF7ED"],
  ["streak/border",      "#FDBA74"],
  ["streak/text",        "#EA580C"],
];

for (const [name, hex] of sharedColors) {
  createColorVar(colorsCollection, name, lightModeId, darkModeId, hex);
}

// --- Colors where Light !== Dark -------------------------------------------

const themedColors = [
  //  name                        light       dark
  ["semantic/background",        "#F9FAFB",  "#111827"],
  ["semantic/surface",           "#FFFFFF",  "#1F2937"],
  ["semantic/surface-elevated",  "#F3F4F6",  "#374151"],
  ["semantic/text-primary",      "#111827",  "#F9FAFB"],
  ["semantic/text-secondary",    "#4B5563",  "#D1D5DB"],
  ["semantic/border",            "#E5E7EB",  "#374151"],
];

for (const [name, lightHex, darkHex] of themedColors) {
  createColorVar(colorsCollection, name, lightModeId, darkModeId, lightHex, darkHex);
}

// ---------------------------------------------------------------------------
// 2. FocusApp Spacing  (single default mode)
// ---------------------------------------------------------------------------

const spacingCollection = figma.variables.createVariableCollection("FocusApp Spacing");
const spacingModeId = spacingCollection.modes[0].modeId;

const spacingValues = [
  ["space/2",  2],
  ["space/4",  4],
  ["space/8",  8],
  ["space/12", 12],
  ["space/16", 16],
  ["space/24", 24],
  ["space/32", 32],
  ["space/48", 48],
  ["space/64", 64],
];

for (const [name, value] of spacingValues) {
  createFloatVar(spacingCollection, name, spacingModeId, value);
}

// ---------------------------------------------------------------------------
// 3. FocusApp Radii  (single default mode)
// ---------------------------------------------------------------------------

const radiiCollection = figma.variables.createVariableCollection("FocusApp Radii");
const radiiModeId = radiiCollection.modes[0].modeId;

const radiiValues = [
  ["radius/small",  8],
  ["radius/medium", 12],
  ["radius/large",  16],
  ["radius/pill",   9999],
];

for (const [name, value] of radiiValues) {
  createFloatVar(radiiCollection, name, radiiModeId, value);
}

// ---------------------------------------------------------------------------
// 4. FocusApp Sizing  (single default mode)
// ---------------------------------------------------------------------------

const sizingCollection = figma.variables.createVariableCollection("FocusApp Sizing");
const sizingModeId = sizingCollection.modes[0].modeId;

const sizingValues = [
  ["size/tab-bar-height",    83],
  ["size/header-height",     44],
  ["size/sidebar-width",     260],
  ["size/widget-width",      350],
  ["size/widget-height",     560],
  ["size/task-row-height",   56],
  ["size/settings-row-height", 56],
  ["size/timer-ring-iphone", 280],
  ["size/timer-ring-ipad",   400],
  ["size/timer-ring-mac",    360],
];

for (const [name, value] of sizingValues) {
  createFloatVar(sizingCollection, name, sizingModeId, value);
}

// ---------------------------------------------------------------------------
// Done
// ---------------------------------------------------------------------------

figma.closePlugin("\u2705 Created 62 variables in 4 collections!");
