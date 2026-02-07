const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const BASE = path.join(__dirname, 'screens');
const HTML = path.resolve(__dirname, 'prototype/all-screens-v2.html');

// Labels extracted directly from the HTML — must match exactly
const screens = [
  { name: 'mac/01-today', label: '1. Mac — Today' },
  { name: 'mac/02-plan', label: '2. Mac — Plan' },
  { name: 'mac/03-stats', label: '3. Mac — Stats' },
  { name: 'mac/04-focus-paused', label: '4. Mac — Focus (Paused)' },
  { name: 'mac/05-coding', label: '5. Mac — Coding Environment' },
  { name: 'mac/06-settings', label: '6. Mac — Settings' },
  { name: 'mac/07-focus-duration', label: '7. Mac — Focus (Duration Selector)' },
  { name: 'mac/08-focus-running', label: '8. Mac — Focus (Running)' },
  { name: 'mac/09-focus-complete', label: '9. Mac — Focus (Completion)' },
  { name: 'mac/10-coding-detail', label: '10. Mac — Coding (Problem Detail)' },
  { name: 'mac/11-coding-solution', label: '11. Mac — Coding (Solution Tab)' },
  { name: 'mac/12-coding-output-result', label: '12. Mac — Coding (Output - Result)' },
  { name: 'mac/13-coding-output-console', label: '13. Mac — Coding (Output - Console)' },
  { name: 'mac/14-settings-debug', label: '14. Mac — Settings (Debug Logs)' },
  { name: 'ipad/15-today', label: '15. iPad — Today' },
  { name: 'ipad/16-plan', label: '16. iPad — Plan' },
  { name: 'ipad/17-stats', label: '17. iPad — Stats' },
  { name: 'ipad/18-focus-duration', label: '18. iPad — Focus (Duration Selector)' },
  { name: 'ipad/19-focus-running', label: '19. iPad — Focus (Running)' },
  { name: 'ipad/20-focus-complete', label: '20. iPad — Focus (Completion)' },
  { name: 'ipad/21-focus-short-break', label: '21. iPad — Focus (Short Break)' },
  { name: 'ipad/22-focus-long-break', label: '22. iPad — Focus (Long Break)' },
  { name: 'ipad/23-coding-three-panel', label: '23. iPad — Coding (Three-Panel)' },
  { name: 'ipad/24-settings', label: '24. iPad — Settings' },
  { name: 'iphone/25-today', label: '25. iPhone — Today' },
  { name: 'iphone/26-focus-duration', label: '26. iPhone — Focus (Duration)' },
  { name: 'iphone/27-focus-running', label: '27. iPhone — Focus (Running)' },
  { name: 'iphone/28-focus-complete', label: '28. iPhone — Focus (Completion)' },
  { name: 'iphone/29-focus-short-break', label: '29. iPhone — Focus (Short Break)' },
  { name: 'iphone/30-focus-long-break', label: '30. iPhone — Focus (Long Break)' },
  { name: 'iphone/31-coding-description', label: '31. iPhone — Coding (Description)' },
  { name: 'iphone/32-coding-solution', label: '32. iPhone — Coding (Solution)' },
  { name: 'iphone/33-coding-code', label: '33. iPhone — Coding (Code)' },
  { name: 'iphone/34-coding-search', label: '34. iPhone — Coding (Search)' },
  { name: 'iphone/35-settings', label: '35. iPhone — Settings' },
  { name: 'iphone/36-today-scrolled', label: '36. iPhone — Today (Scrolled)' },
  { name: 'widget/37-default', label: '37. Widget — Default' },
  { name: 'widget/38-settings-open', label: '38. Widget — Settings Panel' },
  { name: 'widget/39-tomorrow-expanded', label: '39. Widget — Tomorrow Expanded' },
  { name: 'widget/40-all-complete', label: '40. Widget — All Complete' },
  { name: 'widget/41-syncing', label: '41. Widget — Syncing' },
  { name: 'datajourney/42-linked-list', label: '42. Data Journey — Linked List' },
  { name: 'datajourney/43-binary-tree', label: '43. Data Journey — Binary Tree' },
  { name: 'datajourney/44-graph', label: '44. Data Journey — Graph' },
  { name: 'datajourney/45-variable-timeline', label: '45. Data Journey — Variable Timeline' },
  { name: 'datajourney/46-matrix-grid', label: '46. Data Journey — Matrix Grid' },
  { name: 'coding-detail/47-hidden-test-progress', label: '47. Coding — Hidden Test Progress' },
  { name: 'coding-detail/48-leetcode-accepted', label: '48. Coding — LeetCode Accepted' },
  { name: 'coding-detail/49-wrong-answer', label: '49. Coding — Wrong Answer' },
  { name: 'coding-detail/50-test-case-editor', label: '50. Coding — Test Case Editor' },
];

(async () => {
  const dirs = [...new Set(screens.map(s => path.dirname(path.join(BASE, s.name))))];
  for (const dir of dirs) { fs.mkdirSync(dir, { recursive: true }); }

  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1920, height: 30000 }, deviceScaleFactor: 2 });
  await page.goto(`file://${HTML}`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(2000);

  const screenData = await page.evaluate(() => {
    const wrappers = document.querySelectorAll('.screen-wrapper');
    return Array.from(wrappers).map((w, i) => ({
      index: i,
      label: w.querySelector('.screen-name')?.textContent?.trim() || '',
    }));
  });

  console.log(`Found ${screenData.length} screen wrappers\n`);
  let captured = 0, failed = 0;

  for (const screen of screens) {
    const outPath = path.join(BASE, `${screen.name}.png`);
    try {
      const match = screenData.find(d => d.label === screen.label);
      if (!match) { console.log(`⚠ No match: "${screen.label}"`); failed++; continue; }

      const wrapper = page.locator('.screen-wrapper').nth(match.index);
      // Screenshot the wrapper — includes the label + device frame
      await wrapper.screenshot({ path: outPath, type: 'png' });

      const stat = fs.statSync(outPath);
      console.log(`✓ ${screen.name}.png (${Math.round(stat.size / 1024)}KB)`);
      captured++;
    } catch (err) {
      console.log(`✗ ${screen.label}: ${err.message.substring(0, 100)}`);
      failed++;
    }
  }

  await browser.close();
  console.log(`\n✅ Captured: ${captured}/${screens.length} (${failed} failed)`);
  console.log(`📁 Output: ${BASE}/`);
})();
