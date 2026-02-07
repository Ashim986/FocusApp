const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const BASE = path.join(__dirname, 'screens');
const HTML = path.resolve(__dirname, 'prototype/all-screens.html');

// Each screen definition: CSS selector to locate, crop dimensions, output path
const screens = [
  // Mac screens (1200x760 + border/shadow padding)
  { name: 'mac/01-today',    label: 'Mac — Today' },
  { name: 'mac/02-plan',     label: 'Mac — Plan' },
  { name: 'mac/03-stats',    label: 'Mac — Stats' },
  { name: 'mac/04-focus',    label: 'Mac — Focus' },
  { name: 'mac/05-coding',   label: 'Mac — Coding Environment' },
  { name: 'mac/06-settings', label: 'Mac — Settings' },
  // iPad screens (834x700)
  { name: 'ipad/01-today',    label: 'iPad — Today' },
  { name: 'ipad/02-plan',     label: 'iPad — Plan' },
  { name: 'ipad/03-stats',    label: 'iPad — Stats' },
  { name: 'ipad/04-focus',    label: 'iPad — Focus' },
  { name: 'ipad/05-coding',   label: 'iPad — Coding' },
  { name: 'ipad/06-settings', label: 'iPad — Settings' },
  // iPhone screens (393x852)
  { name: 'iphone/01-today',    label: 'iPhone — Today' },
  { name: 'iphone/02-plan',     label: 'iPhone — Plan' },
  { name: 'iphone/03-stats',    label: 'iPhone — Stats' },
  { name: 'iphone/04-focus',    label: 'iPhone — Focus' },
  { name: 'iphone/05-coding',   label: 'iPhone — Coding' },
  { name: 'iphone/06-settings', label: 'iPhone — Settings' },
  // Widget
  { name: 'widget/01-floating-widget', label: 'Floating Widget — macOS' },
];

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: 1920, height: 10000 },
    deviceScaleFactor: 2, // 2x for Retina quality
  });

  await page.goto(`file://${HTML}`, { waitUntil: 'networkidle' });

  // Wait for rendering
  await page.waitForTimeout(1000);

  for (const screen of screens) {
    const outPath = path.join(BASE, `${screen.name}.png`);

    // Find the screen wrapper by its label text
    const wrapper = await page.locator('.screen-wrapper').filter({
      has: page.locator('.screen-name', { hasText: screen.label })
    }).first();

    // Get the actual device frame element (mac/ipad/iphone/widget div) — it's the child after screen-name
    const deviceFrame = await wrapper.locator('.mac, .ipad, .iphone, div[style*="width:350px"]').first();

    try {
      const box = await deviceFrame.boundingBox();
      if (!box) {
        console.log(`⚠ Could not find bounds for: ${screen.label}`);
        continue;
      }

      await deviceFrame.screenshot({
        path: outPath,
        type: 'png',
      });

      const stat = fs.statSync(outPath);
      console.log(`✓ ${screen.name}.png (${Math.round(stat.size / 1024)}KB)`);
    } catch (err) {
      console.log(`✗ ${screen.label}: ${err.message}`);
    }
  }

  await browser.close();
  console.log('\n✅ All screen captures complete!');
  console.log(`📁 Output: ${BASE}/`);
})();
