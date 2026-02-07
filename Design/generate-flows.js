const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const BASE = path.join(__dirname, 'screens', 'flows');

// Flow diagram definitions per platform
const flows = [
  {
    name: 'iphone-app-flow',
    title: 'iPhone App Flow',
    subtitle: '393 × 852 • Bottom Tab Navigation',
    width: 2800,
    height: 1200,
    screens: [
      { tab: 'Today', icon: '🏠', highlight: true },
      { tab: 'Plan', icon: '📅' },
      { tab: 'Stats', icon: '📊' },
      { tab: 'Focus', icon: '⚡' },
      { tab: 'Coding', icon: '💻' },
      { tab: 'Settings', icon: '⚙' },
    ],
    navigation: 'Tab Bar',
    arrows: [
      { from: 0, to: 3, label: 'Start Focus CTA' },
      { from: 0, to: 4, label: 'Problem tap' },
      { from: 4, to: 3, label: 'Focus from Code' },
    ],
  },
  {
    name: 'ipad-app-flow',
    title: 'iPad App Flow',
    subtitle: '834 × 700 • Sidebar Navigation',
    width: 2800,
    height: 1200,
    screens: [
      { tab: 'Today', icon: '🏠', highlight: true },
      { tab: 'Plan', icon: '📅' },
      { tab: 'Stats', icon: '📊' },
      { tab: 'Focus', icon: '⚡' },
      { tab: 'Coding', icon: '💻' },
      { tab: 'Settings', icon: '⚙' },
    ],
    navigation: 'Sidebar',
    arrows: [
      { from: 0, to: 3, label: 'Start Focus CTA' },
      { from: 0, to: 4, label: 'Problem tap' },
      { from: 4, to: 3, label: 'Focus from Code' },
    ],
  },
  {
    name: 'mac-app-flow',
    title: 'Mac App Flow',
    subtitle: '1200 × 760 • Sidebar Navigation + Floating Widget',
    width: 3200,
    height: 1400,
    screens: [
      { tab: 'Today', icon: '🏠', highlight: true },
      { tab: 'Plan', icon: '📅' },
      { tab: 'Stats', icon: '📊' },
      { tab: 'Focus', icon: '⚡' },
      { tab: 'Coding', icon: '💻' },
      { tab: 'Settings', icon: '⚙' },
      { tab: 'Widget', icon: '🧠', isWidget: true },
    ],
    navigation: 'Sidebar + MenuBarExtra',
    arrows: [
      { from: 0, to: 3, label: 'Start Focus CTA' },
      { from: 0, to: 4, label: 'Problem tap' },
      { from: 4, to: 3, label: 'Focus from Code' },
      { from: 6, to: 0, label: 'Widget ↔ Main', bidirectional: true },
    ],
  },
  {
    name: 'focus-timer-flow',
    title: 'Focus Timer Flow',
    subtitle: 'Pomodoro Cycle • All Platforms',
    width: 2400,
    height: 800,
    screens: [
      { tab: 'Paused (25:00)', icon: '⏸', highlight: true },
      { tab: 'Running', icon: '▶' },
      { tab: 'Short Break (5:00)', icon: '☕' },
      { tab: 'Running (2nd)', icon: '▶' },
      { tab: 'Long Break (15:00)', icon: '🌙' },
      { tab: 'Complete', icon: '✅' },
    ],
    navigation: 'Timer States',
    arrows: [
      { from: 0, to: 1, label: 'Start' },
      { from: 1, to: 2, label: 'Timer ends' },
      { from: 2, to: 3, label: 'Start' },
      { from: 3, to: 4, label: 'After 4 cycles' },
      { from: 4, to: 5, label: 'Session done' },
    ],
    isLinear: true,
  },
  {
    name: 'coding-flow',
    title: 'Coding Environment Flow',
    subtitle: 'Problem Selection → Code → Submit',
    width: 2400,
    height: 800,
    screens: [
      { tab: 'Problem List', icon: '📋', highlight: true },
      { tab: 'Problem Detail', icon: '📝' },
      { tab: 'Code Editor', icon: '💻' },
      { tab: 'Run Tests', icon: '▶' },
      { tab: 'Hidden Tests', icon: '🔒' },
      { tab: 'LeetCode Submit', icon: '🚀' },
    ],
    navigation: 'Code Flow',
    arrows: [
      { from: 0, to: 1, label: 'Select problem' },
      { from: 1, to: 2, label: 'Start coding' },
      { from: 2, to: 3, label: 'Run' },
      { from: 3, to: 4, label: 'Submit' },
      { from: 4, to: 5, label: 'All pass' },
    ],
    isLinear: true,
  },
];

function generateFlowHTML(flow) {
  const screenCount = flow.screens.length;
  const cardW = flow.isLinear ? 280 : 320;
  const cardH = flow.isLinear ? 180 : 220;
  const gap = flow.isLinear ? 100 : 120;
  const topPadding = 160;
  const rowY = topPadding + 60;

  // Calculate positions
  const totalWidth = screenCount * cardW + (screenCount - 1) * gap;
  const startX = (flow.width - totalWidth) / 2;

  const positions = flow.screens.map((s, i) => ({
    x: startX + i * (cardW + gap),
    y: rowY,
    cx: startX + i * (cardW + gap) + cardW / 2,
    cy: rowY + cardH / 2,
  }));

  // Build SVG arrows
  let arrowsSVG = '';
  for (const arrow of flow.arrows) {
    const from = positions[arrow.from];
    const to = positions[arrow.to];

    if (flow.isLinear || Math.abs(arrow.to - arrow.from) === 1) {
      // Straight horizontal arrow
      const x1 = from.x + cardW;
      const y1 = from.cy;
      const x2 = to.x;
      const y2 = to.cy;
      const midX = (x1 + x2) / 2;

      arrowsSVG += `
        <line x1="${x1}" y1="${y1}" x2="${x2 - 8}" y2="${y2}" stroke="#6366F1" stroke-width="2.5" marker-end="url(#arrowhead)"/>
        <rect x="${midX - 50}" y="${y1 - 24}" width="100" height="20" rx="10" fill="#EEF2FF" stroke="#C7D2FE" stroke-width="1"/>
        <text x="${midX}" y="${y1 - 11}" text-anchor="middle" font-size="10" font-weight="600" fill="#6366F1">${arrow.label}</text>
      `;
    } else {
      // Curved arrow for non-adjacent screens
      const x1 = from.cx;
      const y1 = from.y + cardH;
      const x2 = to.cx;
      const y2 = to.y + cardH;
      const curveY = y1 + 80 + Math.abs(arrow.to - arrow.from) * 30;

      arrowsSVG += `
        <path d="M${x1},${y1} C${x1},${curveY} ${x2},${curveY} ${x2},${y2}" fill="none" stroke="#8B5CF6" stroke-width="2" stroke-dasharray="6,4" marker-end="url(#arrowhead2)"/>
        <rect x="${(x1 + x2) / 2 - 55}" y="${curveY - 14}" width="110" height="20" rx="10" fill="#F5F3FF" stroke="#DDD6FE" stroke-width="1"/>
        <text x="${(x1 + x2) / 2}" y="${curveY - 1}" text-anchor="middle" font-size="10" font-weight="600" fill="#7C3AED">${arrow.label}</text>
      `;
    }
  }

  // Build screen cards
  let cardsSVG = '';
  for (let i = 0; i < screenCount; i++) {
    const s = flow.screens[i];
    const p = positions[i];
    const isHighlight = s.highlight;
    const isWidget = s.isWidget;

    const fill = isHighlight ? '#6366F1' : isWidget ? '#1F2937' : '#FFFFFF';
    const textColor = isHighlight || isWidget ? '#FFFFFF' : '#111827';
    const subtextColor = isHighlight || isWidget ? 'rgba(255,255,255,0.7)' : '#6B7280';
    const borderColor = isHighlight ? '#4F46E5' : isWidget ? '#374151' : '#E5E7EB';
    const iconBg = isHighlight ? 'rgba(255,255,255,0.2)' : isWidget ? 'rgba(255,255,255,0.1)' : '#F3F4F6';

    cardsSVG += `
      <g>
        <rect x="${p.x}" y="${p.y}" width="${cardW}" height="${cardH}" rx="16" fill="${fill}" stroke="${borderColor}" stroke-width="2" filter="url(#shadow)"/>
        <circle cx="${p.cx}" cy="${p.y + (flow.isLinear ? 55 : 70)}" r="${flow.isLinear ? 28 : 36}" fill="${iconBg}"/>
        <text x="${p.cx}" y="${p.y + (flow.isLinear ? 62 : 78)}" text-anchor="middle" font-size="${flow.isLinear ? 24 : 30}">${s.icon}</text>
        <text x="${p.cx}" y="${p.y + (flow.isLinear ? 110 : 130)}" text-anchor="middle" font-size="${flow.isLinear ? 15 : 17}" font-weight="700" fill="${textColor}">${s.tab}</text>
        ${!flow.isLinear ? `<text x="${p.cx}" y="${p.y + 155}" text-anchor="middle" font-size="12" fill="${subtextColor}">Screen ${i + 1}</text>` : ''}
        <text x="${p.cx}" y="${p.y - 12}" text-anchor="middle" font-size="11" font-weight="600" fill="#9CA3AF">${String(i + 1).padStart(2, '0')}</text>
      </g>
    `;
  }

  return `<!DOCTYPE html>
<html><head><meta charset="UTF-8"><style>
  body { margin: 0; padding: 0; background: #FAFAFA; }
</style></head><body>
<svg xmlns="http://www.w3.org/2000/svg" width="${flow.width}" height="${flow.height}" viewBox="0 0 ${flow.width} ${flow.height}">
  <defs>
    <filter id="shadow" x="-4%" y="-4%" width="108%" height="116%">
      <feDropShadow dx="0" dy="4" stdDeviation="8" flood-opacity="0.08"/>
    </filter>
    <marker id="arrowhead" markerWidth="10" markerHeight="8" refX="9" refY="4" orient="auto">
      <polygon points="0,0 10,4 0,8" fill="#6366F1"/>
    </marker>
    <marker id="arrowhead2" markerWidth="10" markerHeight="8" refX="9" refY="4" orient="auto">
      <polygon points="0,0 10,4 0,8" fill="#8B5CF6"/>
    </marker>
  </defs>

  <!-- Background -->
  <rect width="${flow.width}" height="${flow.height}" fill="#FAFAFA" rx="0"/>

  <!-- Header -->
  <text x="${flow.width / 2}" y="50" text-anchor="middle" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro', system-ui, sans-serif" font-size="32" font-weight="800" fill="#111827">${flow.title}</text>
  <text x="${flow.width / 2}" y="78" text-anchor="middle" font-family="-apple-system, system-ui, sans-serif" font-size="16" fill="#6B7280">${flow.subtitle}</text>

  <!-- Navigation badge -->
  <rect x="${flow.width / 2 - 80}" y="92" width="160" height="28" rx="14" fill="#EEF2FF" stroke="#C7D2FE" stroke-width="1"/>
  <text x="${flow.width / 2}" y="110" text-anchor="middle" font-family="-apple-system, system-ui, sans-serif" font-size="12" font-weight="600" fill="#6366F1">Navigation: ${flow.navigation}</text>

  <!-- Arrows (behind cards) -->
  ${arrowsSVG}

  <!-- Screen cards -->
  ${cardsSVG}

  <!-- Footer -->
  <text x="${flow.width / 2}" y="${flow.height - 30}" text-anchor="middle" font-family="-apple-system, system-ui, sans-serif" font-size="13" fill="#9CA3AF">FocusApp • ${flow.title} • ${screenCount} Screens</text>
</svg>
</body></html>`;
}

(async () => {
  const browser = await chromium.launch();

  for (const flow of flows) {
    const html = generateFlowHTML(flow);
    const tmpHTML = path.join(BASE, `_tmp_${flow.name}.html`);
    fs.writeFileSync(tmpHTML, html);

    const page = await browser.newPage({
      viewport: { width: flow.width, height: flow.height },
      deviceScaleFactor: 2,
    });

    await page.goto(`file://${tmpHTML}`, { waitUntil: 'networkidle' });
    await page.waitForTimeout(500);

    const outPath = path.join(BASE, `${flow.name}.png`);
    await page.screenshot({ path: outPath, type: 'png', fullPage: false });

    const stat = fs.statSync(outPath);
    console.log(`✓ ${flow.name}.png (${Math.round(stat.size / 1024)}KB)`);

    await page.close();
    fs.unlinkSync(tmpHTML); // Clean up temp file
  }

  await browser.close();
  console.log('\n✅ All flow diagrams generated!');
  console.log(`📁 Output: ${BASE}/`);
})();
