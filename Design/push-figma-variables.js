#!/usr/bin/env node

/**
 * push-figma-variables.js
 *
 * Pushes FocusApp design system variables (colors, spacing, radii, sizing)
 * to a Figma file using the Figma Variables REST API.
 *
 * Usage: node push-figma-variables.js
 */

const https = require("https");

const FILE_KEY = "UKttCWGNEqmslRboCqlgqj";
const FIGMA_TOKEN = process.env.FIGMA_TOKEN;

if (!FIGMA_TOKEN) {
  console.error("Missing FIGMA_TOKEN environment variable.");
  console.error("Usage: FIGMA_TOKEN=<your_token> node Design/push-figma-variables.js");
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function hexToRgba(hex) {
  const h = hex.replace("#", "");
  const r = parseInt(h.substring(0, 2), 16) / 255;
  const g = parseInt(h.substring(2, 4), 16) / 255;
  const b = parseInt(h.substring(4, 6), 16) / 255;
  return { r: round(r), g: round(g), b: round(b), a: 1 };
}

function round(n) {
  return Math.round(n * 1000) / 1000;
}

// Unique temp-id generator (must start with a letter)
let idCounter = 0;
function tempId(prefix) {
  idCounter += 1;
  return prefix + "_" + idCounter;
}

// ---------------------------------------------------------------------------
// 1. FocusApp Colors (Light + Dark modes)
// ---------------------------------------------------------------------------

const colorsCollectionId = tempId("coll");
const lightModeId = tempId("mode");
const darkModeId = tempId("mode");

// Each entry: [name, lightHex, darkHex]
const colorDefs = [
  // brand
  ["brand/purple", "#6366F1", "#6366F1"],
  ["brand/indigo", "#1E1B4B", "#1E1B4B"],
  ["brand/indigo-light", "#312E81", "#312E81"],
  ["brand/green", "#10B981", "#10B981"],
  ["brand/green-light", "#D1FAE5", "#D1FAE5"],
  ["brand/cyan", "#22D3EE", "#22D3EE"],
  ["brand/amber", "#F59E0B", "#F59E0B"],
  ["brand/amber-light", "#FEF3C7", "#FEF3C7"],
  ["brand/red", "#EF4444", "#EF4444"],
  ["brand/red-light", "#FEE2E2", "#FEE2E2"],
  // neutral
  ["neutral/gray-50", "#F9FAFB", "#F9FAFB"],
  ["neutral/gray-100", "#F3F4F6", "#F3F4F6"],
  ["neutral/gray-200", "#E5E7EB", "#E5E7EB"],
  ["neutral/gray-300", "#D1D5DB", "#D1D5DB"],
  ["neutral/gray-400", "#9CA3AF", "#9CA3AF"],
  ["neutral/gray-500", "#6B7280", "#6B7280"],
  ["neutral/gray-600", "#4B5563", "#4B5563"],
  ["neutral/gray-700", "#374151", "#374151"],
  ["neutral/gray-800", "#1F2937", "#1F2937"],
  ["neutral/gray-900", "#111827", "#111827"],
  // semantic
  ["semantic/background", "#F9FAFB", "#111827"],
  ["semantic/surface", "#FFFFFF", "#1F2937"],
  ["semantic/surface-elevated", "#F3F4F6", "#374151"],
  ["semantic/text-primary", "#111827", "#F9FAFB"],
  ["semantic/text-secondary", "#4B5563", "#D1D5DB"],
  ["semantic/border", "#E5E7EB", "#374151"],
  ["semantic/accent", "#6366F1", "#6366F1"],
  ["semantic/success", "#10B981", "#10B981"],
  ["semantic/warning", "#F59E0B", "#F59E0B"],
  ["semantic/danger", "#EF4444", "#EF4444"],
  // difficulty
  ["difficulty/easy-bg", "#D1FAE5", "#D1FAE5"],
  ["difficulty/easy-text", "#059669", "#059669"],
  ["difficulty/medium-bg", "#FEF3C7", "#FEF3C7"],
  ["difficulty/medium-text", "#D97706", "#D97706"],
  ["difficulty/hard-bg", "#FEE2E2", "#FEE2E2"],
  ["difficulty/hard-text", "#DC2626", "#DC2626"],
  // streak
  ["streak/background", "#FFF7ED", "#FFF7ED"],
  ["streak/border", "#FDBA74", "#FDBA74"],
  ["streak/text", "#EA580C", "#EA580C"],
];

// Build color variables + mode values
const colorVariables = [];
const colorModeValues = [];

for (const [name, lightHex, darkHex] of colorDefs) {
  const varId = tempId("var");
  colorVariables.push({
    action: "CREATE",
    id: varId,
    name: name,
    variableCollectionId: colorsCollectionId,
    resolvedType: "COLOR",
    scopes: ["ALL_SCOPES"],
  });
  colorModeValues.push({
    variableId: varId,
    modeId: lightModeId,
    value: hexToRgba(lightHex),
  });
  colorModeValues.push({
    variableId: varId,
    modeId: darkModeId,
    value: hexToRgba(darkHex),
  });
}

// ---------------------------------------------------------------------------
// 2. FocusApp Spacing (single Default mode)
// ---------------------------------------------------------------------------

const spacingCollectionId = tempId("coll");
const spacingModeId = tempId("mode");

const spacingDefs = [
  ["space/2", 2],
  ["space/4", 4],
  ["space/8", 8],
  ["space/12", 12],
  ["space/16", 16],
  ["space/24", 24],
  ["space/32", 32],
  ["space/48", 48],
  ["space/64", 64],
];

const spacingVariables = [];
const spacingModeValues = [];

for (const [name, value] of spacingDefs) {
  const varId = tempId("var");
  spacingVariables.push({
    action: "CREATE",
    id: varId,
    name: name,
    variableCollectionId: spacingCollectionId,
    resolvedType: "FLOAT",
    scopes: ["ALL_SCOPES"],
  });
  spacingModeValues.push({
    variableId: varId,
    modeId: spacingModeId,
    value: value,
  });
}

// ---------------------------------------------------------------------------
// 3. FocusApp Radii (single Default mode)
// ---------------------------------------------------------------------------

const radiiCollectionId = tempId("coll");
const radiiModeId = tempId("mode");

const radiiDefs = [
  ["radius/small", 8],
  ["radius/medium", 12],
  ["radius/large", 16],
  ["radius/pill", 9999],
];

const radiiVariables = [];
const radiiModeValues = [];

for (const [name, value] of radiiDefs) {
  const varId = tempId("var");
  radiiVariables.push({
    action: "CREATE",
    id: varId,
    name: name,
    variableCollectionId: radiiCollectionId,
    resolvedType: "FLOAT",
    scopes: ["ALL_SCOPES"],
  });
  radiiModeValues.push({
    variableId: varId,
    modeId: radiiModeId,
    value: value,
  });
}

// ---------------------------------------------------------------------------
// 4. FocusApp Sizing (single Default mode)
// ---------------------------------------------------------------------------

const sizingCollectionId = tempId("coll");
const sizingModeId = tempId("mode");

const sizingDefs = [
  ["size/tab-bar-height", 83],
  ["size/header-height", 44],
  ["size/sidebar-width", 260],
  ["size/widget-width", 350],
  ["size/widget-height", 560],
  ["size/task-row-height", 56],
  ["size/settings-row-height", 56],
  ["size/timer-ring-iphone", 280],
  ["size/timer-ring-ipad", 400],
  ["size/timer-ring-mac", 360],
];

const sizingVariables = [];
const sizingModeValues = [];

for (const [name, value] of sizingDefs) {
  const varId = tempId("var");
  sizingVariables.push({
    action: "CREATE",
    id: varId,
    name: name,
    variableCollectionId: sizingCollectionId,
    resolvedType: "FLOAT",
    scopes: ["ALL_SCOPES"],
  });
  sizingModeValues.push({
    variableId: varId,
    modeId: sizingModeId,
    value: value,
  });
}

// ---------------------------------------------------------------------------
// Assemble the full request body
// ---------------------------------------------------------------------------

const body = {
  variableCollections: [
    {
      action: "CREATE",
      id: colorsCollectionId,
      name: "FocusApp Colors",
      initialModeId: lightModeId,
    },
    {
      action: "CREATE",
      id: spacingCollectionId,
      name: "FocusApp Spacing",
      initialModeId: spacingModeId,
    },
    {
      action: "CREATE",
      id: radiiCollectionId,
      name: "FocusApp Radii",
      initialModeId: radiiModeId,
    },
    {
      action: "CREATE",
      id: sizingCollectionId,
      name: "FocusApp Sizing",
      initialModeId: sizingModeId,
    },
  ],
  variableModes: [
    // Colors: rename initial mode to "Light", add "Dark"
    {
      action: "UPDATE",
      id: lightModeId,
      name: "Light",
      variableCollectionId: colorsCollectionId,
    },
    {
      action: "CREATE",
      id: darkModeId,
      name: "Dark",
      variableCollectionId: colorsCollectionId,
    },
    // Spacing: rename initial mode to "Default"
    {
      action: "UPDATE",
      id: spacingModeId,
      name: "Default",
      variableCollectionId: spacingCollectionId,
    },
    // Radii: rename initial mode to "Default"
    {
      action: "UPDATE",
      id: radiiModeId,
      name: "Default",
      variableCollectionId: radiiCollectionId,
    },
    // Sizing: rename initial mode to "Default"
    {
      action: "UPDATE",
      id: sizingModeId,
      name: "Default",
      variableCollectionId: sizingCollectionId,
    },
  ],
  variables: [
    ...colorVariables,
    ...spacingVariables,
    ...radiiVariables,
    ...sizingVariables,
  ],
  variableModeValues: [
    ...colorModeValues,
    ...spacingModeValues,
    ...radiiModeValues,
    ...sizingModeValues,
  ],
};

// ---------------------------------------------------------------------------
// Send the request
// ---------------------------------------------------------------------------

const payload = JSON.stringify(body);

console.log("Pushing design system variables to Figma...");
console.log("  File key: " + FILE_KEY);
console.log("  Collections: " + body.variableCollections.length);
console.log("  Variables: " + body.variables.length);
console.log("  Mode values: " + body.variableModeValues.length);
console.log("");

const options = {
  hostname: "api.figma.com",
  port: 443,
  path: "/v1/files/" + FILE_KEY + "/variables",
  method: "POST",
  headers: {
    "X-Figma-Token": FIGMA_TOKEN,
    "Content-Type": "application/json",
    "Content-Length": Buffer.byteLength(payload),
  },
};

const req = https.request(options, (res) => {
  let data = "";
  res.on("data", (chunk) => {
    data += chunk;
  });
  res.on("end", () => {
    console.log("Response status: " + res.statusCode);
    try {
      const parsed = JSON.parse(data);
      if (res.statusCode === 200) {
        console.log("SUCCESS: Variables created in Figma.");
        // Summarize what was created
        if (parsed.meta) {
          const meta = parsed.meta;
          if (meta.variableCollections) {
            const collections = Object.values(meta.variableCollections);
            console.log("\nCreated " + collections.length + " collection(s):");
            for (const c of collections) {
              console.log("  - " + c.name + " (id: " + c.id + ")");
            }
          }
          if (meta.variables) {
            const vars = Object.values(meta.variables);
            console.log("\nCreated " + vars.length + " variable(s).");
          }
        }
      } else {
        console.log("FAILED:");
        console.log(JSON.stringify(parsed, null, 2));
      }
    } catch (e) {
      console.log("Raw response:");
      console.log(data);
    }
  });
});

req.on("error", (err) => {
  console.error("Request error:", err.message);
  process.exit(1);
});

req.write(payload);
req.end();
