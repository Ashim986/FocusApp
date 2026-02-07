// FocusApp Screens Generator — Figma Plugin
// Creates iPhone and iPad screen frames with full UI mockups.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function hex(h) {
  h = h.replace('#', '');
  return {
    r: parseInt(h.substr(0, 2), 16) / 255,
    g: parseInt(h.substr(2, 2), 16) / 255,
    b: parseInt(h.substr(4, 2), 16) / 255,
  };
}

function solid(hexColor, opacity) {
  const paint = { type: 'SOLID', color: hex(hexColor) };
  if (opacity !== undefined) paint.opacity = opacity;
  return [paint];
}

function gradient(hex1, hex2) {
  return [
    {
      type: 'GRADIENT_LINEAR',
      gradientStops: [
        { position: 0, color: { ...hex(hex1), a: 1 } },
        { position: 1, color: { ...hex(hex2), a: 1 } },
      ],
      gradientTransform: [
        [1, 0, 0],
        [0, 1, 0],
      ],
    },
  ];
}

// Create a frame with auto-layout helpers
function autoFrame(name, dir, opts) {
  const f = figma.createFrame();
  f.name = name;
  f.layoutMode = dir; // 'VERTICAL' | 'HORIZONTAL'
  f.primaryAxisSizingMode = (opts && opts.primarySize) || 'AUTO';
  f.counterAxisSizingMode = (opts && opts.counterSize) || 'AUTO';
  if (opts && opts.w) { f.resize(opts.w, opts.h || 10); }
  if (opts && opts.fill) f.fills = opts.fill;
  else f.fills = [];
  if (opts && opts.padding !== undefined) {
    f.paddingLeft = opts.padding;
    f.paddingRight = opts.padding;
    f.paddingTop = opts.padding;
    f.paddingBottom = opts.padding;
  }
  if (opts && opts.px !== undefined) { f.paddingLeft = opts.px; f.paddingRight = opts.px; }
  if (opts && opts.py !== undefined) { f.paddingTop = opts.py; f.paddingBottom = opts.py; }
  if (opts && opts.pt !== undefined) f.paddingTop = opts.pt;
  if (opts && opts.pb !== undefined) f.paddingBottom = opts.pb;
  if (opts && opts.pl !== undefined) f.paddingLeft = opts.pl;
  if (opts && opts.pr !== undefined) f.paddingRight = opts.pr;
  if (opts && opts.gap !== undefined) f.itemSpacing = opts.gap;
  if (opts && opts.radius !== undefined) f.cornerRadius = opts.radius;
  if (opts && opts.clip) f.clipsContent = true;
  if (opts && opts.stroke) {
    f.strokes = solid(opts.stroke);
    f.strokeWeight = opts.strokeWeight || 1;
  }
  if (opts && opts.strokeAlign) f.strokeAlign = opts.strokeAlign;
  return f;
}

async function txt(content, size, fontStyle, colorHex, opts) {
  const t = figma.createText();
  const style = fontStyle || 'Regular';
  await figma.loadFontAsync({ family: 'Inter', style: style });
  t.fontName = { family: 'Inter', style: style };
  t.characters = content;
  t.fontSize = size;
  if (colorHex) t.fills = solid(colorHex);
  if (opts && opts.opacity !== undefined) t.opacity = opts.opacity;
  if (opts && opts.lineThrough) {
    t.textDecoration = 'STRIKETHROUGH';
  }
  if (opts && opts.uppercase) {
    t.textCase = 'UPPER';
  }
  return t;
}

function circle(size, fillHex) {
  const e = figma.createEllipse();
  e.resize(size, size);
  if (fillHex) e.fills = solid(fillHex);
  return e;
}

function rect(w, h, fillHex, opts) {
  const r = figma.createRectangle();
  r.resize(w, h);
  if (fillHex) r.fills = solid(fillHex);
  else r.fills = [];
  if (opts && opts.radius !== undefined) r.cornerRadius = opts.radius;
  if (opts && opts.stroke) {
    r.strokes = solid(opts.stroke);
    r.strokeWeight = opts.strokeWeight || 1;
  }
  if (opts && opts.opacity !== undefined) r.opacity = opts.opacity;
  if (opts && opts.dashPattern) r.dashPattern = opts.dashPattern;
  return r;
}

// Fill width helper — sets layoutAlign and grow
function fillW(node) {
  node.layoutAlign = 'STRETCH';
  return node;
}

function fillGrow(node) {
  node.layoutGrow = 1;
  return node;
}

// Spacer
function spacer(h) {
  const f = figma.createFrame();
  f.name = 'Spacer';
  f.resize(1, h);
  f.fills = [];
  f.layoutAlign = 'STRETCH';
  return f;
}

// Difficulty badge
async function badge(level) {
  const colors = {
    Easy: { bg: '#DCFCE7', text: '#15803D' },
    Medium: { bg: '#FEF3C7', text: '#B45309' },
    Hard: { bg: '#FEE2E2', text: '#DC2626' },
  };
  const c = colors[level] || colors.Easy;
  const f = autoFrame('Badge ' + level, 'HORIZONTAL', { fill: solid(c.bg), px: 8, py: 2, radius: 9999, gap: 0 });
  const t = await txt(level, 11, 'Semi Bold', c.text);
  f.appendChild(t);
  return f;
}

// Checkmark or empty circle
function checkIcon(done) {
  if (done) {
    const e = circle(20, '#22C55E');
    e.name = 'Check';
    return e;
  }
  const e = circle(20, null);
  e.fills = [];
  e.strokes = solid('#D1D5DB');
  e.strokeWeight = 1.5;
  e.name = 'Empty';
  return e;
}

// Find or create a page by name
function findOrCreatePage(name) {
  let page = figma.root.children.find(p => p.name === name);
  if (!page) {
    page = figma.createPage();
    page.name = name;
  }
  return page;
}

// ---------------------------------------------------------------------------
// iPhone Tab Bar
// ---------------------------------------------------------------------------
async function iPhoneTabBar(activeTab) {
  const tabs = [
    { name: 'Today', icon: 'house' },
    { name: 'Plan', icon: 'calendar' },
    { name: 'Stats', icon: 'chart' },
    { name: 'Focus', icon: 'timer' },
    { name: 'Coding', icon: 'code' },
    { name: 'Settings', icon: 'gear' },
  ];
  const bar = autoFrame('Tab Bar', 'HORIZONTAL', {
    fill: solid('#FFFFFF'),
    pt: 8, pb: 28, px: 0, gap: 0,
    stroke: '#E5E7EB',
    strokeAlign: 'INSIDE',
  });
  bar.strokesIncludedInLayout = false;
  bar.layoutAlign = 'STRETCH';
  bar.primaryAxisSizingMode = 'FIXED';
  bar.counterAxisSizingMode = 'AUTO';

  for (const tab of tabs) {
    const isActive = tab.name === activeTab;
    const col = isActive ? '#6366F1' : '#9CA3AF';
    const item = autoFrame(tab.name, 'VERTICAL', { gap: 2, padding: 0 });
    item.counterAxisAlignItems = 'CENTER';
    item.layoutGrow = 1;
    const ic = circle(20, col);
    ic.name = tab.icon;
    item.appendChild(ic);
    const label = await txt(tab.name, 10, 'Medium', col);
    item.appendChild(label);
    bar.appendChild(item);
  }
  return bar;
}

// ---------------------------------------------------------------------------
// iPhone Status Bar (spacer)
// ---------------------------------------------------------------------------
function statusBar() {
  return spacer(44);
}

// ---------------------------------------------------------------------------
// iPhone Header
// ---------------------------------------------------------------------------
async function header(title) {
  const h = autoFrame('Header', 'HORIZONTAL', { gap: 0, py: 10, px: 16 });
  h.layoutAlign = 'STRETCH';
  h.counterAxisAlignItems = 'CENTER';
  const sp1 = figma.createFrame(); sp1.name = 'left-spacer'; sp1.resize(20, 20); sp1.fills = []; sp1.layoutGrow = 1;
  const t = await txt(title, 16, 'Semi Bold', '#111827');
  const gear = circle(20, '#D1D5DB');
  gear.name = 'Gear Icon';
  h.appendChild(sp1);
  h.appendChild(t);
  const sp2 = figma.createFrame(); sp2.name = 'right-spacer'; sp2.resize(1, 1); sp2.fills = []; sp2.layoutGrow = 1;
  h.appendChild(sp2);
  h.appendChild(gear);
  return h;
}

// ---------------------------------------------------------------------------
// Task Row (for Today screen)
// ---------------------------------------------------------------------------
async function taskRow(title, tags, difficulty, done) {
  const row = autoFrame('Task: ' + title, 'HORIZONTAL', { gap: 12, px: 16, py: 12 });
  row.layoutAlign = 'STRETCH';
  row.counterAxisAlignItems = 'CENTER';

  row.appendChild(checkIcon(done));

  const info = autoFrame('Info', 'VERTICAL', { gap: 2 });
  info.layoutGrow = 1;
  const titleText = await txt(title, 14, 'Semi Bold', done ? '#9CA3AF' : '#111827', { lineThrough: done });
  info.appendChild(titleText);
  const tagsText = await txt(tags, 12, 'Regular', '#9CA3AF');
  info.appendChild(tagsText);
  row.appendChild(info);

  const b = await badge(difficulty);
  row.appendChild(b);
  return row;
}

// ---------------------------------------------------------------------------
// SCREEN BUILDERS — IPHONE
// ---------------------------------------------------------------------------

async function buildIPhoneToday(parent) {
  const screen = autoFrame('iPhone \u2014 Today', 'VERTICAL', {
    w: 393, h: 852, fill: solid('#FFFFFF'), clip: true, gap: 0,
  });
  screen.primaryAxisSizingMode = 'FIXED';
  screen.counterAxisSizingMode = 'FIXED';

  // Status bar
  screen.appendChild(statusBar());

  // Header
  screen.appendChild(await header('FocusApp'));

  // Scrollable content wrapper
  const content = autoFrame('Content', 'VERTICAL', { gap: 12, px: 16, pt: 4, pb: 8 });
  content.layoutAlign = 'STRETCH';
  content.layoutGrow = 1;
  content.clipsContent = true;

  // Date
  content.appendChild(await txt('FRIDAY, FEBRUARY 7', 12, 'Medium', '#6B7280'));

  // Greeting
  content.appendChild(await txt('Good Morning', 24, 'Bold', '#111827'));

  // Streak badge
  const streakRow = autoFrame('Streak', 'HORIZONTAL', {
    fill: solid('#FFF7ED'), px: 12, py: 6, radius: 9999, gap: 4,
    stroke: '#FDBA74',
  });
  const streakTxt = await txt('\uD83D\uDD25 12 Day Streak', 13, 'Semi Bold', '#EA580C');
  streakRow.appendChild(streakTxt);
  content.appendChild(streakRow);

  // Daily Goal Card
  const goalCard = autoFrame('Daily Goal Card', 'VERTICAL', {
    fill: gradient('#6366F1', '#8B5CF6'), radius: 16, padding: 20, gap: 8,
  });
  goalCard.layoutAlign = 'STRETCH';
  goalCard.appendChild(await txt('Daily Goal', 14, 'Regular', '#FFFFFF', { opacity: 0.9 }));
  goalCard.appendChild(await txt('1/4', 28, 'Bold', '#FFFFFF'));
  goalCard.appendChild(await txt('Tasks completed', 14, 'Regular', '#FFFFFF', { opacity: 0.8 }));
  const progressBg = rect(321, 6, '#FFFFFF', { radius: 3, opacity: 0.3 });
  progressBg.layoutAlign = 'STRETCH';
  goalCard.appendChild(progressBg);
  const progressFill = rect(80, 6, '#FFFFFF', { radius: 3 });
  goalCard.appendChild(progressFill);
  content.appendChild(goalCard);

  // Focus Time Card
  const focusCard = autoFrame('Focus Time Card', 'HORIZONTAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 12, gap: 12,
    stroke: '#E5E7EB',
  });
  focusCard.layoutAlign = 'STRETCH';
  focusCard.counterAxisAlignItems = 'CENTER';
  focusCard.appendChild(circle(40, '#D1FAE5'));
  const fcInfo = autoFrame('FC Info', 'VERTICAL', { gap: 2 });
  fcInfo.layoutGrow = 1;
  fcInfo.appendChild(await txt('Focus Time', 14, 'Regular', '#6B7280'));
  fcInfo.appendChild(await txt('2h 15m', 18, 'Bold', '#111827'));
  focusCard.appendChild(fcInfo);
  content.appendChild(focusCard);

  // Start Focus CTA
  const ctaCard = autoFrame('Start Focus CTA', 'HORIZONTAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 12, gap: 12,
  });
  ctaCard.layoutAlign = 'STRETCH';
  ctaCard.counterAxisAlignItems = 'CENTER';
  ctaCard.strokes = solid('#6366F1');
  ctaCard.strokeWeight = 1;
  ctaCard.dashPattern = [4, 4];
  ctaCard.appendChild(circle(40, '#EEF2FF'));
  const ctaInfo = autoFrame('CTA Info', 'VERTICAL', { gap: 2 });
  ctaInfo.layoutGrow = 1;
  ctaInfo.appendChild(await txt('Start Focus Session', 14, 'Semi Bold', '#111827'));
  ctaInfo.appendChild(await txt('Ready to get in the zone?', 12, 'Regular', '#6B7280'));
  ctaCard.appendChild(ctaInfo);
  content.appendChild(ctaCard);

  // Today's Plan header
  const planHeader = autoFrame("Today's Plan Header", 'HORIZONTAL', { gap: 0 });
  planHeader.layoutAlign = 'STRETCH';
  planHeader.counterAxisAlignItems = 'CENTER';
  const planTitle = await txt("Today's Plan", 16, 'Semi Bold', '#111827');
  planTitle.layoutGrow = 1;
  planHeader.appendChild(planTitle);
  planHeader.appendChild(await txt('View Full Plan', 14, 'Semi Bold', '#6366F1'));
  content.appendChild(planHeader);

  // Task rows
  content.appendChild(await taskRow('Two Sum', 'Array, Hash Table', 'Easy', true));
  content.appendChild(await taskRow('Valid Parentheses', 'Stack', 'Easy', false));
  content.appendChild(await taskRow('Merge Intervals', 'Array, Sorting', 'Medium', false));
  content.appendChild(await taskRow('LRU Cache', 'Hash Table, Linked List', 'Hard', false));

  screen.appendChild(content);

  // Tab Bar
  screen.appendChild(await iPhoneTabBar('Today'));

  parent.appendChild(screen);
  return screen;
}

async function buildIPhonePlan(parent) {
  const screen = autoFrame('iPhone \u2014 Plan', 'VERTICAL', {
    w: 393, h: 852, fill: solid('#FFFFFF'), clip: true, gap: 0,
  });
  screen.primaryAxisSizingMode = 'FIXED';
  screen.counterAxisSizingMode = 'FIXED';
  screen.x = 493;

  screen.appendChild(statusBar());
  screen.appendChild(await header('FocusApp'));

  const content = autoFrame('Content', 'VERTICAL', { gap: 16, px: 16, pt: 4, pb: 8 });
  content.layoutAlign = 'STRETCH';
  content.layoutGrow = 1;
  content.clipsContent = true;

  content.appendChild(await txt('Study Plan', 18, 'Bold', '#111827'));

  // Calendar card
  const calCard = autoFrame('Calendar Card', 'VERTICAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 12,
    stroke: '#E5E7EB',
  });
  calCard.layoutAlign = 'STRETCH';

  // Month header
  const monthRow = autoFrame('Month', 'HORIZONTAL', { gap: 0 });
  monthRow.layoutAlign = 'STRETCH';
  monthRow.counterAxisAlignItems = 'CENTER';
  monthRow.appendChild(await txt('\u25C0', 14, 'Regular', '#6B7280'));
  const monthLabel = await txt('February 2026', 16, 'Semi Bold', '#111827');
  monthLabel.layoutGrow = 1;
  monthLabel.textAlignHorizontal = 'CENTER';
  monthRow.appendChild(monthLabel);
  monthRow.appendChild(await txt('\u25B6', 14, 'Regular', '#6B7280'));
  calCard.appendChild(monthRow);

  // Weekday row
  const weekdays = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];
  const wdRow = autoFrame('Weekdays', 'HORIZONTAL', { gap: 0 });
  wdRow.layoutAlign = 'STRETCH';
  for (const wd of weekdays) {
    const cell = autoFrame(wd, 'VERTICAL', { gap: 0 });
    cell.layoutGrow = 1;
    cell.counterAxisAlignItems = 'CENTER';
    cell.primaryAxisAlignItems = 'CENTER';
    cell.resize(44, 24);
    cell.primaryAxisSizingMode = 'FIXED';
    cell.appendChild(await txt(wd, 12, 'Medium', '#9CA3AF'));
    wdRow.appendChild(cell);
  }
  calCard.appendChild(wdRow);

  // Date grid — simplified: just 1 row showing days 1-7 with day 7 selected
  const days = [
    [null, null, null, null, null, null, 1],
    [2, 3, 4, 5, 6, 7, 8],
    [9, 10, 11, 12, 13, 14, 15],
    [16, 17, 18, 19, 20, 21, 22],
    [23, 24, 25, 26, 27, 28, null],
  ];
  for (const week of days) {
    const row = autoFrame('Week', 'HORIZONTAL', { gap: 0 });
    row.layoutAlign = 'STRETCH';
    for (const d of week) {
      const cell = autoFrame('Day', 'VERTICAL', { gap: 0 });
      cell.layoutGrow = 1;
      cell.counterAxisAlignItems = 'CENTER';
      cell.primaryAxisAlignItems = 'CENTER';
      cell.resize(44, 44);
      cell.primaryAxisSizingMode = 'FIXED';
      cell.counterAxisSizingMode = 'FIXED';
      if (d !== null) {
        if (d === 7) {
          const sel = circle(36, '#6366F1');
          cell.appendChild(sel);
          const dayTxt = await txt(String(d), 14, 'Semi Bold', '#FFFFFF');
          dayTxt.layoutPositioning = 'ABSOLUTE';
          dayTxt.x = 14;
          dayTxt.y = 13;
          cell.appendChild(dayTxt);
        } else {
          cell.appendChild(await txt(String(d), 14, 'Regular', '#374151'));
          if (d === 6) {
            const dot = circle(4, '#6366F1');
            cell.appendChild(dot);
          }
        }
      }
      row.appendChild(cell);
    }
    calCard.appendChild(row);
  }
  content.appendChild(calCard);

  // Schedule section
  content.appendChild(await txt('Schedule for February 7th', 18, 'Semi Bold', '#111827'));

  // Schedule row builder
  async function scheduleRow(time, title, desc, active) {
    const row = autoFrame('Schedule: ' + title, 'HORIZONTAL', {
      fill: solid(active ? '#EEF2FF' : '#F9FAFB'), radius: 12, padding: 12, gap: 12,
    });
    row.layoutAlign = 'STRETCH';
    if (active) {
      const bar = rect(3, 40, '#6366F1', { radius: 2 });
      row.appendChild(bar);
    }
    const info = autoFrame('Info', 'VERTICAL', { gap: 2 });
    info.layoutGrow = 1;
    info.appendChild(await txt(time, 12, 'Semi Bold', active ? '#6366F1' : '#6B7280'));
    info.appendChild(await txt(title, 14, 'Semi Bold', '#111827'));
    info.appendChild(await txt(desc, 12, 'Regular', '#6B7280'));
    row.appendChild(info);
    return row;
  }

  content.appendChild(await scheduleRow('09:00 AM', 'Morning Review', "Review yesterday's problems", true));
  content.appendChild(await scheduleRow('10:30 AM', 'Graph Theory', 'BFS and DFS practice', false));
  const mockRow = await scheduleRow('02:00 PM', 'Mock Interview', 'System Design', false);
  mockRow.opacity = 0.5;
  content.appendChild(mockRow);

  screen.appendChild(content);
  screen.appendChild(await iPhoneTabBar('Plan'));

  parent.appendChild(screen);
  return screen;
}

async function buildIPhoneStats(parent) {
  const screen = autoFrame('iPhone \u2014 Stats', 'VERTICAL', {
    w: 393, h: 852, fill: solid('#FFFFFF'), clip: true, gap: 0,
  });
  screen.primaryAxisSizingMode = 'FIXED';
  screen.counterAxisSizingMode = 'FIXED';
  screen.x = 986;

  screen.appendChild(statusBar());
  screen.appendChild(await header('FocusApp'));

  const content = autoFrame('Content', 'VERTICAL', { gap: 16, px: 16, pt: 4, pb: 8 });
  content.layoutAlign = 'STRETCH';
  content.layoutGrow = 1;
  content.clipsContent = true;

  content.appendChild(await txt('Your Statistics', 18, 'Bold', '#111827'));

  // Bar Chart Card
  const barCard = autoFrame('Bar Chart', 'VERTICAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 8,
    stroke: '#E5E7EB',
  });
  barCard.layoutAlign = 'STRETCH';
  barCard.appendChild(await txt('Weekly Activity', 14, 'Semi Bold', '#111827'));
  const barsRow = autoFrame('Bars', 'HORIZONTAL', { gap: 8 });
  barsRow.layoutAlign = 'STRETCH';
  barsRow.counterAxisAlignItems = 'MAX';
  const barHeights = [60, 80, 45, 90, 70, 40, 55];
  const barDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  for (let i = 0; i < 7; i++) {
    const col = autoFrame(barDays[i], 'VERTICAL', { gap: 4 });
    col.layoutGrow = 1;
    col.counterAxisAlignItems = 'CENTER';
    col.primaryAxisAlignItems = 'MAX';
    const bar = rect(24, barHeights[i], '#6366F1', { radius: 4 });
    col.appendChild(bar);
    col.appendChild(await txt(barDays[i], 11, 'Regular', '#9CA3AF'));
    barsRow.appendChild(col);
  }
  barCard.appendChild(barsRow);
  content.appendChild(barCard);

  // Line Chart Card
  const lineCard = autoFrame('Line Chart', 'VERTICAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 8,
    stroke: '#E5E7EB',
  });
  lineCard.layoutAlign = 'STRETCH';
  lineCard.appendChild(await txt('Focus Trend', 14, 'Semi Bold', '#111827'));
  // Simplified line chart — dots
  const dotsRow = autoFrame('Dots', 'HORIZONTAL', { gap: 20 });
  dotsRow.layoutAlign = 'STRETCH';
  dotsRow.counterAxisAlignItems = 'CENTER';
  dotsRow.primaryAxisAlignItems = 'SPACE_BETWEEN';
  const dotYs = [30, 50, 40, 70, 60, 80, 65];
  for (let i = 0; i < 7; i++) {
    const wrapper = autoFrame('Dot Wrapper', 'VERTICAL', { gap: 0 });
    wrapper.layoutGrow = 1;
    wrapper.counterAxisAlignItems = 'CENTER';
    wrapper.appendChild(spacer(80 - dotYs[i]));
    wrapper.appendChild(circle(8, '#22C55E'));
    wrapper.appendChild(spacer(dotYs[i]));
    dotsRow.appendChild(wrapper);
  }
  lineCard.appendChild(dotsRow);
  content.appendChild(lineCard);

  // Metric cards 2x2
  async function metricCard(label, value, trend) {
    const c = autoFrame('Metric: ' + label, 'VERTICAL', {
      fill: solid('#FFFFFF'), radius: 12, padding: 12, gap: 4,
      stroke: '#E5E7EB',
    });
    c.layoutGrow = 1;
    c.appendChild(await txt(label, 12, 'Regular', '#6B7280'));
    c.appendChild(await txt(value, 20, 'Bold', '#111827'));
    if (trend) c.appendChild(await txt(trend, 12, 'Medium', '#22C55E'));
    return c;
  }
  const row1 = autoFrame('Metrics Row 1', 'HORIZONTAL', { gap: 12 });
  row1.layoutAlign = 'STRETCH';
  row1.appendChild(await metricCard('Problems Solved', '47', '\u2191 12%'));
  row1.appendChild(await metricCard('Focus Hours', '23.5h', '\u2191 8%'));
  content.appendChild(row1);
  const row2 = autoFrame('Metrics Row 2', 'HORIZONTAL', { gap: 12 });
  row2.layoutAlign = 'STRETCH';
  row2.appendChild(await metricCard('Current Streak', '12 days', '\uD83D\uDD25'));
  row2.appendChild(await metricCard('Completion Rate', '78%', '\u2191 5%'));
  content.appendChild(row2);

  screen.appendChild(content);
  screen.appendChild(await iPhoneTabBar('Stats'));

  parent.appendChild(screen);
  return screen;
}

async function buildIPhoneFocus(parent) {
  const screen = autoFrame('iPhone \u2014 Focus', 'VERTICAL', {
    w: 393, h: 852, fill: solid('#FFFFFF'), clip: true, gap: 0,
  });
  screen.primaryAxisSizingMode = 'FIXED';
  screen.counterAxisSizingMode = 'FIXED';
  screen.x = 1479;

  screen.appendChild(statusBar());

  // Header row
  const hdr = autoFrame('Header', 'HORIZONTAL', { gap: 0, px: 16, py: 10 });
  hdr.layoutAlign = 'STRETCH';
  hdr.counterAxisAlignItems = 'CENTER';
  const hdrTitle = await txt('Focus', 18, 'Bold', '#111827');
  hdrTitle.layoutGrow = 1;
  hdr.appendChild(hdrTitle);
  const sessionsBadge = autoFrame('Sessions Badge', 'HORIZONTAL', {
    fill: solid('#F3F4F6'), px: 10, py: 4, radius: 9999, gap: 0,
  });
  sessionsBadge.appendChild(await txt('Sessions: 3', 12, 'Medium', '#374151'));
  hdr.appendChild(sessionsBadge);
  screen.appendChild(hdr);

  const content = autoFrame('Content', 'VERTICAL', { gap: 20, px: 16, pt: 8, pb: 8 });
  content.layoutAlign = 'STRETCH';
  content.layoutGrow = 1;
  content.clipsContent = true;

  // Segmented Control
  const seg = autoFrame('Segmented Control', 'HORIZONTAL', {
    fill: solid('#F3F4F6'), padding: 4, gap: 0, radius: 12,
  });
  seg.layoutAlign = 'STRETCH';
  const segments = ['Focus', 'Short Break', 'Long Break'];
  for (const s of segments) {
    const isActive = s === 'Focus';
    const segItem = autoFrame(s, 'HORIZONTAL', {
      fill: isActive ? solid('#FFFFFF') : [],
      px: 16, py: 8, radius: 10, gap: 0,
    });
    segItem.layoutGrow = 1;
    segItem.primaryAxisAlignItems = 'CENTER';
    segItem.counterAxisAlignItems = 'CENTER';
    segItem.appendChild(await txt(s, 13, 'Semi Bold', isActive ? '#111827' : '#6B7280'));
    seg.appendChild(segItem);
  }
  content.appendChild(seg);

  // Timer Card
  const timerCard = autoFrame('Timer Card', 'VERTICAL', {
    fill: solid('#FEE2E2'), radius: 16, padding: 24, gap: 16,
  });
  timerCard.layoutAlign = 'STRETCH';
  timerCard.counterAxisAlignItems = 'CENTER';

  // Timer ring — outer track
  const ringContainer = autoFrame('Ring Container', 'VERTICAL', { gap: 0 });
  ringContainer.counterAxisAlignItems = 'CENTER';
  ringContainer.primaryAxisAlignItems = 'CENTER';
  ringContainer.resize(280, 280);
  ringContainer.primaryAxisSizingMode = 'FIXED';
  ringContainer.counterAxisSizingMode = 'FIXED';

  // Track circle
  const track = circle(280, null);
  track.fills = [];
  track.strokes = solid('#E5E7EB');
  track.strokeWeight = 8;
  track.name = 'Track';
  track.layoutPositioning = 'ABSOLUTE';
  track.x = 0;
  track.y = 0;
  ringContainer.appendChild(track);

  // Progress arc (represented as a partial ellipse — Figma plugins use arcData)
  const progress = figma.createEllipse();
  progress.resize(280, 280);
  progress.fills = [];
  progress.strokes = solid('#DC2626');
  progress.strokeWeight = 8;
  progress.arcData = { startingAngle: -Math.PI / 2, endingAngle: Math.PI * 1.0, innerRadius: 0.94 };
  progress.name = 'Progress';
  progress.layoutPositioning = 'ABSOLUTE';
  progress.x = 0;
  progress.y = 0;
  ringContainer.appendChild(progress);

  // Center text
  const timerText = await txt('24:54', 64, 'Bold', '#111827');
  timerText.layoutPositioning = 'ABSOLUTE';
  timerText.x = 52;
  timerText.y = 100;
  ringContainer.appendChild(timerText);

  const runningLabel = await txt('RUNNING', 12, 'Semi Bold', '#DC2626');
  runningLabel.layoutPositioning = 'ABSOLUTE';
  runningLabel.x = 105;
  runningLabel.y = 170;
  ringContainer.appendChild(runningLabel);

  timerCard.appendChild(ringContainer);
  content.appendChild(timerCard);

  // Buttons row
  const btnRow = autoFrame('Buttons', 'HORIZONTAL', { gap: 12 });
  btnRow.layoutAlign = 'STRETCH';
  const pauseBtn = autoFrame('Pause', 'HORIZONTAL', {
    fill: solid('#DC2626'), radius: 12, py: 14, px: 0, gap: 0,
  });
  pauseBtn.layoutGrow = 1;
  pauseBtn.primaryAxisAlignItems = 'CENTER';
  pauseBtn.counterAxisAlignItems = 'CENTER';
  pauseBtn.appendChild(await txt('Pause', 16, 'Semi Bold', '#FFFFFF'));
  btnRow.appendChild(pauseBtn);
  const resetBtn = autoFrame('Reset', 'HORIZONTAL', {
    fill: solid('#F3F4F6'), radius: 12, gap: 0,
  });
  resetBtn.resize(48, 48);
  resetBtn.primaryAxisSizingMode = 'FIXED';
  resetBtn.counterAxisSizingMode = 'FIXED';
  resetBtn.primaryAxisAlignItems = 'CENTER';
  resetBtn.counterAxisAlignItems = 'CENTER';
  const resetIcon = circle(16, '#6B7280');
  resetBtn.appendChild(resetIcon);
  btnRow.appendChild(resetBtn);
  content.appendChild(btnRow);

  // Current Focus
  content.appendChild(await txt('CURRENT FOCUS', 12, 'Medium', '#6B7280'));
  const focusTag = autoFrame('Focus Tag', 'HORIZONTAL', {
    fill: solid('#F3F4F6'), radius: 8, px: 12, py: 8, gap: 0,
  });
  focusTag.layoutAlign = 'STRETCH';
  focusTag.appendChild(await txt('Arrays & Hashing', 14, 'Semi Bold', '#111827'));
  content.appendChild(focusTag);

  screen.appendChild(content);
  screen.appendChild(await iPhoneTabBar('Focus'));

  parent.appendChild(screen);
  return screen;
}

async function buildIPhoneCoding(parent) {
  const screen = autoFrame('iPhone \u2014 Coding', 'VERTICAL', {
    w: 393, h: 852, fill: solid('#FFFFFF'), clip: true, gap: 0,
  });
  screen.primaryAxisSizingMode = 'FIXED';
  screen.counterAxisSizingMode = 'FIXED';
  screen.x = 1972;

  screen.appendChild(statusBar());
  screen.appendChild(await header('FocusApp'));

  const content = autoFrame('Content', 'VERTICAL', { gap: 12, px: 16, pt: 8, pb: 8 });
  content.layoutAlign = 'STRETCH';
  content.layoutGrow = 1;
  content.clipsContent = true;

  // Search bar
  const search = autoFrame('Search Bar', 'HORIZONTAL', {
    fill: solid('#F3F4F6'), radius: 10, px: 12, py: 10, gap: 8,
  });
  search.layoutAlign = 'STRETCH';
  search.counterAxisAlignItems = 'CENTER';
  search.appendChild(circle(16, '#9CA3AF'));
  search.appendChild(await txt('Search problems...', 14, 'Regular', '#9CA3AF'));
  content.appendChild(search);

  // Problem cards
  const problems = [
    { name: 'Two Sum', diff: 'Easy', done: true },
    { name: 'Valid Parentheses', diff: 'Easy', done: true },
    { name: 'Merge Intervals', diff: 'Medium', done: false },
    { name: 'LRU Cache', diff: 'Hard', done: false },
    { name: 'Binary Search', diff: 'Easy', done: false },
    { name: '3Sum', diff: 'Medium', done: false },
  ];

  for (const p of problems) {
    const card = autoFrame('Problem: ' + p.name, 'HORIZONTAL', {
      fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 12,
      stroke: '#E5E7EB',
    });
    card.layoutAlign = 'STRETCH';
    card.counterAxisAlignItems = 'CENTER';

    const info = autoFrame('Info', 'VERTICAL', { gap: 4 });
    info.layoutGrow = 1;
    info.appendChild(await txt(p.name, 14, 'Semi Bold', '#111827'));
    info.appendChild(await badge(p.diff));
    card.appendChild(info);

    if (p.done) {
      card.appendChild(circle(20, '#22C55E'));
    } else {
      const emptyCircle = circle(20, null);
      emptyCircle.fills = [];
      emptyCircle.strokes = solid('#D1D5DB');
      emptyCircle.strokeWeight = 1.5;
      card.appendChild(emptyCircle);
    }
    content.appendChild(card);
  }

  screen.appendChild(content);
  screen.appendChild(await iPhoneTabBar('Coding'));

  parent.appendChild(screen);
  return screen;
}

async function buildIPhoneSettings(parent) {
  const screen = autoFrame('iPhone \u2014 Settings', 'VERTICAL', {
    w: 393, h: 852, fill: solid('#FFFFFF'), clip: true, gap: 0,
  });
  screen.primaryAxisSizingMode = 'FIXED';
  screen.counterAxisSizingMode = 'FIXED';
  screen.x = 2465;

  screen.appendChild(statusBar());
  screen.appendChild(await header('FocusApp'));

  const content = autoFrame('Content', 'VERTICAL', { gap: 16, px: 16, pt: 8, pb: 8 });
  content.layoutAlign = 'STRETCH';
  content.layoutGrow = 1;
  content.clipsContent = true;

  content.appendChild(await txt('Settings', 18, 'Bold', '#111827'));

  // Settings row builder
  async function settingsRow(iconColor, title, subtitle, showChevron) {
    const row = autoFrame('Row: ' + title, 'HORIZONTAL', {
      gap: 12, py: 12, px: 0,
    });
    row.layoutAlign = 'STRETCH';
    row.counterAxisAlignItems = 'CENTER';
    row.appendChild(circle(36, iconColor));
    const info = autoFrame('Info', 'VERTICAL', { gap: 2 });
    info.layoutGrow = 1;
    info.appendChild(await txt(title, 14, 'Regular', '#111827'));
    if (subtitle) info.appendChild(await txt(subtitle, 12, 'Regular', '#6B7280'));
    row.appendChild(info);
    if (showChevron) {
      row.appendChild(await txt('\u203A', 18, 'Regular', '#9CA3AF'));
    }
    return row;
  }

  // ACCOUNT Section
  content.appendChild(await txt('ACCOUNT', 12, 'Medium', '#6B7280'));
  const accountCard = autoFrame('Account Card', 'VERTICAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 0,
    stroke: '#E5E7EB',
  });
  accountCard.layoutAlign = 'STRETCH';
  accountCard.appendChild(await settingsRow('#F3F4F6', 'Profile', 'Ashim Dahal', true));
  const divider1 = rect(329, 1, '#E5E7EB');
  divider1.layoutAlign = 'STRETCH';
  accountCard.appendChild(divider1);
  accountCard.appendChild(await settingsRow('#EEF2FF', 'LeetCode Account', 'ashim986', true));
  content.appendChild(accountCard);

  // PREFERENCES Section
  content.appendChild(await txt('PREFERENCES', 12, 'Medium', '#6B7280'));
  const prefCard = autoFrame('Preferences Card', 'VERTICAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 0,
    stroke: '#E5E7EB',
  });
  prefCard.layoutAlign = 'STRETCH';
  prefCard.appendChild(await settingsRow('#FEF3C7', 'Notifications', 'Enabled', true));
  const divider2 = rect(329, 1, '#E5E7EB');
  divider2.layoutAlign = 'STRETCH';
  prefCard.appendChild(divider2);
  prefCard.appendChild(await settingsRow('#F3F4F6', 'Appearance', 'System', true));
  content.appendChild(prefCard);

  // LEETCODE Section
  content.appendChild(await txt('LEETCODE', 12, 'Medium', '#6B7280'));
  const lcCard = autoFrame('LeetCode Card', 'VERTICAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 0,
    stroke: '#E5E7EB',
  });
  lcCard.layoutAlign = 'STRETCH';
  lcCard.appendChild(await settingsRow('#DCFCE7', 'Sync Status', 'Up to date', true));
  content.appendChild(lcCard);

  // Sign Out
  const signOut = autoFrame('Sign Out', 'HORIZONTAL', {
    fill: solid('#FEE2E2'), radius: 12, py: 14, px: 0, gap: 0,
  });
  signOut.layoutAlign = 'STRETCH';
  signOut.primaryAxisAlignItems = 'CENTER';
  signOut.counterAxisAlignItems = 'CENTER';
  signOut.appendChild(await txt('Sign Out', 16, 'Semi Bold', '#DC2626'));
  content.appendChild(signOut);

  screen.appendChild(content);
  screen.appendChild(await iPhoneTabBar('Settings'));

  parent.appendChild(screen);
  return screen;
}

// ---------------------------------------------------------------------------
// iPad Sidebar
// ---------------------------------------------------------------------------
async function iPadSidebar(activeTab) {
  const sidebar = autoFrame('Sidebar', 'VERTICAL', {
    w: 260, fill: solid('#F9FAFB'), gap: 4, pt: 24, pb: 24, px: 16,
  });
  sidebar.primaryAxisSizingMode = 'FIXED';
  sidebar.counterAxisSizingMode = 'FIXED';
  sidebar.resize(260, 1366);
  sidebar.strokes = [{ type: 'SOLID', color: hex('#E5E7EB') }];
  sidebar.strokeWeight = 1;
  sidebar.strokeAlign = 'INSIDE';

  // App title
  sidebar.appendChild(await txt('FocusApp', 20, 'Bold', '#6366F1'));
  sidebar.appendChild(spacer(24));

  const navItems = [
    { name: 'Today', icon: 'house' },
    { name: 'Plan', icon: 'calendar' },
    { name: 'Stats', icon: 'chart' },
    { name: 'Focus', icon: 'timer' },
    { name: 'Coding', icon: 'code' },
  ];

  for (const item of navItems) {
    const isActive = item.name === activeTab;
    const row = autoFrame('Nav: ' + item.name, 'HORIZONTAL', {
      fill: isActive ? solid('#EEF2FF') : [],
      radius: 8, px: 12, py: 12, gap: 12,
    });
    row.layoutAlign = 'STRETCH';
    row.counterAxisAlignItems = 'CENTER';
    row.appendChild(circle(20, isActive ? '#6366F1' : '#9CA3AF'));
    row.appendChild(await txt(item.name, 14, 'Semi Bold', isActive ? '#6366F1' : '#4B5563'));
    sidebar.appendChild(row);
  }

  // Spacer to push Settings to bottom
  const bottomSpacer = figma.createFrame();
  bottomSpacer.name = 'Bottom Spacer';
  bottomSpacer.fills = [];
  bottomSpacer.layoutGrow = 1;
  bottomSpacer.resize(1, 1);
  sidebar.appendChild(bottomSpacer);

  // Settings at bottom
  const isSettingsActive = activeTab === 'Settings';
  const settingsRow = autoFrame('Nav: Settings', 'HORIZONTAL', {
    fill: isSettingsActive ? solid('#EEF2FF') : [],
    radius: 8, px: 12, py: 12, gap: 12,
  });
  settingsRow.layoutAlign = 'STRETCH';
  settingsRow.counterAxisAlignItems = 'CENTER';
  settingsRow.appendChild(circle(20, isSettingsActive ? '#6366F1' : '#9CA3AF'));
  settingsRow.appendChild(await txt('Settings', 14, 'Semi Bold', isSettingsActive ? '#6366F1' : '#4B5563'));
  sidebar.appendChild(settingsRow);

  return sidebar;
}

// ---------------------------------------------------------------------------
// SCREEN BUILDERS — IPAD
// ---------------------------------------------------------------------------

async function buildIPadToday(parent) {
  const screen = autoFrame('iPad \u2014 Today', 'HORIZONTAL', {
    w: 1024, h: 1366, fill: solid('#FFFFFF'), clip: true, gap: 0,
  });
  screen.primaryAxisSizingMode = 'FIXED';
  screen.counterAxisSizingMode = 'FIXED';

  screen.appendChild(await iPadSidebar('Today'));

  // Main content
  const main = autoFrame('Main', 'VERTICAL', { gap: 16, padding: 32 });
  main.layoutGrow = 1;
  main.layoutAlign = 'STRETCH';
  main.clipsContent = true;

  main.appendChild(await txt('SATURDAY, FEBRUARY 7', 12, 'Medium', '#6B7280'));
  main.appendChild(await txt('Good Morning, John', 32, 'Bold', '#111827'));

  // Streak badge
  const streak = autoFrame('Streak', 'HORIZONTAL', {
    fill: solid('#FFF7ED'), px: 12, py: 6, radius: 9999, gap: 4,
    stroke: '#FDBA74',
  });
  streak.appendChild(await txt('\uD83D\uDD25 12 Day Streak', 13, 'Semi Bold', '#EA580C'));
  main.appendChild(streak);

  // 3 Cards horizontal
  const cardsRow = autoFrame('Cards Row', 'HORIZONTAL', { gap: 16 });
  cardsRow.layoutAlign = 'STRETCH';

  // Daily Goal
  const goalCard = autoFrame('Daily Goal', 'VERTICAL', {
    fill: gradient('#6366F1', '#8B5CF6'), radius: 16, padding: 20, gap: 8,
  });
  goalCard.layoutGrow = 1;
  goalCard.appendChild(await txt('Daily Goal', 14, 'Regular', '#FFFFFF', { opacity: 0.9 }));
  goalCard.appendChild(await txt('1/4', 28, 'Bold', '#FFFFFF'));
  goalCard.appendChild(await txt('Tasks completed', 14, 'Regular', '#FFFFFF', { opacity: 0.8 }));
  const pBar = rect(200, 6, '#FFFFFF', { radius: 3, opacity: 0.3 });
  pBar.layoutAlign = 'STRETCH';
  goalCard.appendChild(pBar);
  cardsRow.appendChild(goalCard);

  // Focus Time
  const focusCard = autoFrame('Focus Time', 'HORIZONTAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 12,
    stroke: '#E5E7EB',
  });
  focusCard.layoutGrow = 1;
  focusCard.counterAxisAlignItems = 'CENTER';
  focusCard.appendChild(circle(40, '#D1FAE5'));
  const ftInfo = autoFrame('FT Info', 'VERTICAL', { gap: 2 });
  ftInfo.appendChild(await txt('Focus Time', 14, 'Regular', '#6B7280'));
  ftInfo.appendChild(await txt('2h 15m', 18, 'Bold', '#111827'));
  focusCard.appendChild(ftInfo);
  cardsRow.appendChild(focusCard);

  // Start Focus
  const ctaCard = autoFrame('Start Focus', 'HORIZONTAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 12,
  });
  ctaCard.layoutGrow = 1;
  ctaCard.counterAxisAlignItems = 'CENTER';
  ctaCard.strokes = solid('#6366F1');
  ctaCard.strokeWeight = 1;
  ctaCard.dashPattern = [4, 4];
  ctaCard.appendChild(circle(40, '#EEF2FF'));
  const ctInfo = autoFrame('CT Info', 'VERTICAL', { gap: 2 });
  ctInfo.appendChild(await txt('Start Focus Session', 14, 'Semi Bold', '#111827'));
  ctInfo.appendChild(await txt('Ready to get in the zone?', 12, 'Regular', '#6B7280'));
  ctaCard.appendChild(ctInfo);
  cardsRow.appendChild(ctaCard);

  main.appendChild(cardsRow);

  // Today's Plan header
  const planHdr = autoFrame("Today's Plan Header", 'HORIZONTAL', { gap: 0 });
  planHdr.layoutAlign = 'STRETCH';
  planHdr.counterAxisAlignItems = 'CENTER';
  const planT = await txt("Today's Plan", 16, 'Semi Bold', '#111827');
  planT.layoutGrow = 1;
  planHdr.appendChild(planT);
  planHdr.appendChild(await txt('View Full Plan', 14, 'Semi Bold', '#6366F1'));
  main.appendChild(planHdr);

  // Tasks
  main.appendChild(await taskRow('Two Sum', 'Array, Hash Table', 'Easy', true));
  main.appendChild(await taskRow('Valid Parentheses', 'Stack', 'Easy', false));
  main.appendChild(await taskRow('Merge Intervals', 'Array, Sorting', 'Medium', false));
  main.appendChild(await taskRow('LRU Cache', 'Hash Table, Linked List', 'Hard', false));

  screen.appendChild(main);
  parent.appendChild(screen);
  return screen;
}

async function buildIPadPlan(parent) {
  const screen = autoFrame('iPad \u2014 Plan', 'HORIZONTAL', {
    w: 1024, h: 1366, fill: solid('#FFFFFF'), clip: true, gap: 0,
  });
  screen.primaryAxisSizingMode = 'FIXED';
  screen.counterAxisSizingMode = 'FIXED';
  screen.x = 1124;

  screen.appendChild(await iPadSidebar('Plan'));

  const main = autoFrame('Main', 'VERTICAL', { gap: 24, padding: 32 });
  main.layoutGrow = 1;
  main.layoutAlign = 'STRETCH';
  main.clipsContent = true;

  main.appendChild(await txt('Study Plan', 24, 'Bold', '#111827'));

  // Two-column layout
  const cols = autoFrame('Columns', 'HORIZONTAL', { gap: 24 });
  cols.layoutAlign = 'STRETCH';
  cols.layoutGrow = 1;

  // Left: Calendar
  const calCol = autoFrame('Calendar Column', 'VERTICAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 12,
    stroke: '#E5E7EB',
  });
  calCol.layoutGrow = 1;

  const monthRow = autoFrame('Month', 'HORIZONTAL', { gap: 0 });
  monthRow.layoutAlign = 'STRETCH';
  monthRow.counterAxisAlignItems = 'CENTER';
  monthRow.appendChild(await txt('\u25C0', 14, 'Regular', '#6B7280'));
  const mLabel = await txt('February 2026', 16, 'Semi Bold', '#111827');
  mLabel.layoutGrow = 1;
  mLabel.textAlignHorizontal = 'CENTER';
  monthRow.appendChild(mLabel);
  monthRow.appendChild(await txt('\u25B6', 14, 'Regular', '#6B7280'));
  calCol.appendChild(monthRow);

  const weekdays = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];
  const wdRow = autoFrame('Weekdays', 'HORIZONTAL', { gap: 0 });
  wdRow.layoutAlign = 'STRETCH';
  for (const wd of weekdays) {
    const cell = autoFrame(wd, 'VERTICAL', { gap: 0 });
    cell.layoutGrow = 1;
    cell.counterAxisAlignItems = 'CENTER';
    cell.appendChild(await txt(wd, 12, 'Medium', '#9CA3AF'));
    wdRow.appendChild(cell);
  }
  calCol.appendChild(wdRow);

  const days = [
    [null, null, null, null, null, null, 1],
    [2, 3, 4, 5, 6, 7, 8],
    [9, 10, 11, 12, 13, 14, 15],
    [16, 17, 18, 19, 20, 21, 22],
    [23, 24, 25, 26, 27, 28, null],
  ];
  for (const week of days) {
    const row = autoFrame('Week', 'HORIZONTAL', { gap: 0 });
    row.layoutAlign = 'STRETCH';
    for (const d of week) {
      const cell = autoFrame('Day', 'VERTICAL', { gap: 0 });
      cell.layoutGrow = 1;
      cell.counterAxisAlignItems = 'CENTER';
      cell.primaryAxisAlignItems = 'CENTER';
      cell.resize(44, 44);
      cell.primaryAxisSizingMode = 'FIXED';
      cell.counterAxisSizingMode = 'FIXED';
      if (d !== null) {
        if (d === 7) {
          const sel = circle(36, '#6366F1');
          cell.appendChild(sel);
          const dt = await txt(String(d), 14, 'Semi Bold', '#FFFFFF');
          dt.layoutPositioning = 'ABSOLUTE';
          dt.x = 17;
          dt.y = 13;
          cell.appendChild(dt);
        } else {
          cell.appendChild(await txt(String(d), 14, 'Regular', '#374151'));
        }
      }
      row.appendChild(cell);
    }
    calCol.appendChild(row);
  }
  cols.appendChild(calCol);

  // Right: Schedule
  const schedCol = autoFrame('Schedule Column', 'VERTICAL', { gap: 16 });
  schedCol.layoutGrow = 1;

  schedCol.appendChild(await txt('Schedule for February 7th', 18, 'Semi Bold', '#111827'));

  async function schedRow(time, title, desc, active) {
    const row = autoFrame('Schedule: ' + title, 'HORIZONTAL', {
      fill: solid(active ? '#EEF2FF' : '#F9FAFB'), radius: 12, padding: 16, gap: 12,
    });
    row.layoutAlign = 'STRETCH';
    if (active) {
      const bar = rect(3, 44, '#6366F1', { radius: 2 });
      row.appendChild(bar);
    }
    const info = autoFrame('Info', 'VERTICAL', { gap: 2 });
    info.layoutGrow = 1;
    info.appendChild(await txt(time, 12, 'Semi Bold', active ? '#6366F1' : '#6B7280'));
    info.appendChild(await txt(title, 14, 'Semi Bold', '#111827'));
    info.appendChild(await txt(desc, 12, 'Regular', '#6B7280'));
    row.appendChild(info);
    return row;
  }

  schedCol.appendChild(await schedRow('09:00 AM', 'Morning Review', "Review yesterday's problems", true));
  schedCol.appendChild(await schedRow('10:30 AM', 'Graph Theory', 'BFS and DFS practice', false));
  const mockRow = await schedRow('02:00 PM', 'Mock Interview', 'System Design', false);
  mockRow.opacity = 0.5;
  schedCol.appendChild(mockRow);
  cols.appendChild(schedCol);

  main.appendChild(cols);
  screen.appendChild(main);
  parent.appendChild(screen);
  return screen;
}

async function buildIPadStats(parent) {
  const screen = autoFrame('iPad \u2014 Stats', 'HORIZONTAL', {
    w: 1024, h: 1366, fill: solid('#FFFFFF'), clip: true, gap: 0,
  });
  screen.primaryAxisSizingMode = 'FIXED';
  screen.counterAxisSizingMode = 'FIXED';
  screen.x = 2248;

  screen.appendChild(await iPadSidebar('Stats'));

  const main = autoFrame('Main', 'VERTICAL', { gap: 24, padding: 32 });
  main.layoutGrow = 1;
  main.layoutAlign = 'STRETCH';
  main.clipsContent = true;

  main.appendChild(await txt('Your Statistics', 24, 'Bold', '#111827'));

  // Charts row
  const chartsRow = autoFrame('Charts Row', 'HORIZONTAL', { gap: 16 });
  chartsRow.layoutAlign = 'STRETCH';

  // Bar Chart
  const barCard = autoFrame('Bar Chart', 'VERTICAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 8,
    stroke: '#E5E7EB',
  });
  barCard.layoutGrow = 1;
  barCard.appendChild(await txt('Weekly Activity', 14, 'Semi Bold', '#111827'));
  const barsRow = autoFrame('Bars', 'HORIZONTAL', { gap: 12 });
  barsRow.layoutAlign = 'STRETCH';
  barsRow.counterAxisAlignItems = 'MAX';
  const barHeights = [60, 80, 45, 90, 70, 40, 55];
  const barDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  for (let i = 0; i < 7; i++) {
    const col = autoFrame(barDays[i], 'VERTICAL', { gap: 4 });
    col.layoutGrow = 1;
    col.counterAxisAlignItems = 'CENTER';
    col.primaryAxisAlignItems = 'MAX';
    col.appendChild(rect(28, barHeights[i], '#6366F1', { radius: 4 }));
    col.appendChild(await txt(barDays[i], 11, 'Regular', '#9CA3AF'));
    barsRow.appendChild(col);
  }
  barCard.appendChild(barsRow);
  chartsRow.appendChild(barCard);

  // Line Chart
  const lineCard = autoFrame('Line Chart', 'VERTICAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 8,
    stroke: '#E5E7EB',
  });
  lineCard.layoutGrow = 1;
  lineCard.appendChild(await txt('Focus Trend', 14, 'Semi Bold', '#111827'));
  const dotsRow = autoFrame('Dots', 'HORIZONTAL', { gap: 20 });
  dotsRow.layoutAlign = 'STRETCH';
  dotsRow.counterAxisAlignItems = 'CENTER';
  const dotYs = [30, 50, 40, 70, 60, 80, 65];
  for (let i = 0; i < 7; i++) {
    const wrapper = autoFrame('Dot', 'VERTICAL', { gap: 0 });
    wrapper.layoutGrow = 1;
    wrapper.counterAxisAlignItems = 'CENTER';
    wrapper.appendChild(spacer(80 - dotYs[i]));
    wrapper.appendChild(circle(8, '#22C55E'));
    wrapper.appendChild(spacer(dotYs[i]));
    dotsRow.appendChild(wrapper);
  }
  lineCard.appendChild(dotsRow);
  chartsRow.appendChild(lineCard);

  main.appendChild(chartsRow);

  // Metrics row — 4 cards
  const metricsRow = autoFrame('Metrics Row', 'HORIZONTAL', { gap: 16 });
  metricsRow.layoutAlign = 'STRETCH';

  async function metricCard(label, value, trend) {
    const c = autoFrame('Metric: ' + label, 'VERTICAL', {
      fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 4,
      stroke: '#E5E7EB',
    });
    c.layoutGrow = 1;
    c.appendChild(await txt(label, 12, 'Regular', '#6B7280'));
    c.appendChild(await txt(value, 24, 'Bold', '#111827'));
    if (trend) c.appendChild(await txt(trend, 12, 'Medium', '#22C55E'));
    return c;
  }

  metricsRow.appendChild(await metricCard('Problems Solved', '47', '\u2191 12%'));
  metricsRow.appendChild(await metricCard('Focus Hours', '23.5h', '\u2191 8%'));
  metricsRow.appendChild(await metricCard('Current Streak', '12 days', '\uD83D\uDD25'));
  metricsRow.appendChild(await metricCard('Completion Rate', '78%', '\u2191 5%'));
  main.appendChild(metricsRow);

  screen.appendChild(main);
  parent.appendChild(screen);
  return screen;
}

async function buildIPadFocus(parent) {
  const screen = autoFrame('iPad \u2014 Focus', 'HORIZONTAL', {
    w: 1024, h: 1366, fill: solid('#FFFFFF'), clip: true, gap: 0,
  });
  screen.primaryAxisSizingMode = 'FIXED';
  screen.counterAxisSizingMode = 'FIXED';
  screen.x = 3372;

  screen.appendChild(await iPadSidebar('Focus'));

  const main = autoFrame('Main', 'VERTICAL', { gap: 24, padding: 32 });
  main.layoutGrow = 1;
  main.layoutAlign = 'STRETCH';
  main.counterAxisAlignItems = 'CENTER';
  main.primaryAxisAlignItems = 'CENTER';
  main.clipsContent = true;

  main.appendChild(await txt('Deep Work Session', 24, 'Bold', '#111827'));
  main.appendChild(await txt('Stay focused and track your progress.', 14, 'Regular', '#6B7280'));

  // Timer ring
  const ringContainer = autoFrame('Ring Container', 'VERTICAL', { gap: 0 });
  ringContainer.counterAxisAlignItems = 'CENTER';
  ringContainer.primaryAxisAlignItems = 'CENTER';
  ringContainer.resize(400, 400);
  ringContainer.primaryAxisSizingMode = 'FIXED';
  ringContainer.counterAxisSizingMode = 'FIXED';

  const track = circle(400, null);
  track.fills = [];
  track.strokes = solid('#E5E7EB');
  track.strokeWeight = 10;
  track.layoutPositioning = 'ABSOLUTE';
  track.x = 0;
  track.y = 0;
  ringContainer.appendChild(track);

  const progress = figma.createEllipse();
  progress.resize(400, 400);
  progress.fills = [];
  progress.strokes = solid('#6366F1');
  progress.strokeWeight = 10;
  progress.arcData = { startingAngle: -Math.PI / 2, endingAngle: Math.PI * 1.5, innerRadius: 0.95 };
  progress.layoutPositioning = 'ABSOLUTE';
  progress.x = 0;
  progress.y = 0;
  ringContainer.appendChild(progress);

  const timerText = await txt('25:00', 64, 'Bold', '#111827');
  timerText.layoutPositioning = 'ABSOLUTE';
  timerText.x = 105;
  timerText.y = 150;
  ringContainer.appendChild(timerText);

  const pausedLabel = await txt('PAUSED', 12, 'Semi Bold', '#9CA3AF');
  pausedLabel.layoutPositioning = 'ABSOLUTE';
  pausedLabel.x = 168;
  pausedLabel.y = 225;
  ringContainer.appendChild(pausedLabel);

  main.appendChild(ringContainer);

  // Buttons
  const btnRow = autoFrame('Buttons', 'HORIZONTAL', { gap: 16 });
  btnRow.counterAxisAlignItems = 'CENTER';

  const playBtn = autoFrame('Play', 'HORIZONTAL', {
    fill: solid('#6366F1'), radius: 9999, gap: 0,
  });
  playBtn.resize(56, 56);
  playBtn.primaryAxisSizingMode = 'FIXED';
  playBtn.counterAxisSizingMode = 'FIXED';
  playBtn.primaryAxisAlignItems = 'CENTER';
  playBtn.counterAxisAlignItems = 'CENTER';
  // Triangle placeholder
  const tri = rect(16, 20, '#FFFFFF', { radius: 2 });
  playBtn.appendChild(tri);
  btnRow.appendChild(playBtn);

  const resetBtn = autoFrame('Reset', 'HORIZONTAL', {
    fill: solid('#F3F4F6'), radius: 9999, gap: 0,
  });
  resetBtn.resize(48, 48);
  resetBtn.primaryAxisSizingMode = 'FIXED';
  resetBtn.counterAxisSizingMode = 'FIXED';
  resetBtn.primaryAxisAlignItems = 'CENTER';
  resetBtn.counterAxisAlignItems = 'CENTER';
  resetBtn.appendChild(circle(16, '#6B7280'));
  btnRow.appendChild(resetBtn);

  main.appendChild(btnRow);

  // Stats row
  const statsRow = autoFrame('Stats', 'HORIZONTAL', { gap: 24 });
  statsRow.counterAxisAlignItems = 'CENTER';
  statsRow.appendChild(await txt('3 SESSIONS', 12, 'Semi Bold', '#6B7280'));
  statsRow.appendChild(await txt('|', 12, 'Regular', '#D1D5DB'));
  statsRow.appendChild(await txt('75m TOTAL FOCUS', 12, 'Semi Bold', '#6B7280'));
  main.appendChild(statsRow);

  screen.appendChild(main);
  parent.appendChild(screen);
  return screen;
}

async function buildIPadCoding(parent) {
  const screen = autoFrame('iPad \u2014 Coding', 'HORIZONTAL', {
    w: 1024, h: 1366, fill: solid('#FFFFFF'), clip: true, gap: 0,
  });
  screen.primaryAxisSizingMode = 'FIXED';
  screen.counterAxisSizingMode = 'FIXED';
  screen.x = 4496;

  screen.appendChild(await iPadSidebar('Coding'));

  // Three-panel layout
  const panels = autoFrame('Panels', 'HORIZONTAL', { gap: 0 });
  panels.layoutGrow = 1;
  panels.layoutAlign = 'STRETCH';

  // Left panel: Problem list
  const leftPanel = autoFrame('Problem List Panel', 'VERTICAL', {
    w: 220, fill: solid('#FAFAFA'), gap: 0, pt: 16, pb: 16, px: 12,
  });
  leftPanel.primaryAxisSizingMode = 'FIXED';
  leftPanel.counterAxisSizingMode = 'FIXED';
  leftPanel.resize(220, 1366);
  leftPanel.strokes = [{ type: 'SOLID', color: hex('#E5E7EB') }];
  leftPanel.strokeWeight = 1;
  leftPanel.strokeAlign = 'INSIDE';

  // Search
  const searchBar = autoFrame('Search', 'HORIZONTAL', {
    fill: solid('#FFFFFF'), radius: 8, px: 8, py: 8, gap: 4,
    stroke: '#E5E7EB',
  });
  searchBar.layoutAlign = 'STRETCH';
  searchBar.appendChild(circle(12, '#9CA3AF'));
  searchBar.appendChild(await txt('Search...', 12, 'Regular', '#9CA3AF'));
  leftPanel.appendChild(searchBar);
  leftPanel.appendChild(spacer(12));

  const problemNames = ['Two Sum', 'Valid Parentheses', 'Merge Intervals', 'LRU Cache', 'Binary Search', '3Sum'];
  const diffs = ['Easy', 'Easy', 'Medium', 'Hard', 'Easy', 'Medium'];
  for (let i = 0; i < problemNames.length; i++) {
    const isSelected = i === 0;
    const row = autoFrame('P: ' + problemNames[i], 'VERTICAL', {
      fill: isSelected ? solid('#EEF2FF') : [],
      radius: 8, px: 8, py: 8, gap: 2,
    });
    row.layoutAlign = 'STRETCH';
    row.appendChild(await txt(problemNames[i], 13, 'Semi Bold', isSelected ? '#6366F1' : '#111827'));
    row.appendChild(await badge(diffs[i]));
    leftPanel.appendChild(row);
    leftPanel.appendChild(spacer(4));
  }
  panels.appendChild(leftPanel);

  // Center panel: Problem description
  const centerPanel = autoFrame('Description Panel', 'VERTICAL', {
    fill: solid('#FFFFFF'), gap: 16, padding: 24,
  });
  centerPanel.layoutGrow = 1;
  centerPanel.layoutAlign = 'STRETCH';

  centerPanel.appendChild(await txt('Two Sum', 20, 'Bold', '#111827'));
  centerPanel.appendChild(await badge('Easy'));
  centerPanel.appendChild(await txt(
    'Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.',
    14, 'Regular', '#374151'
  ));

  centerPanel.appendChild(await txt('Example 1:', 14, 'Semi Bold', '#111827'));
  const exampleBox = autoFrame('Example', 'VERTICAL', {
    fill: solid('#F9FAFB'), radius: 8, padding: 12, gap: 4,
  });
  exampleBox.layoutAlign = 'STRETCH';
  exampleBox.appendChild(await txt('Input: nums = [2,7,11,15], target = 9', 13, 'Regular', '#374151'));
  exampleBox.appendChild(await txt('Output: [0,1]', 13, 'Regular', '#374151'));
  centerPanel.appendChild(exampleBox);

  // Run button
  const runBtn = autoFrame('Run', 'HORIZONTAL', {
    fill: solid('#6366F1'), radius: 8, py: 10, px: 24, gap: 4,
  });
  runBtn.primaryAxisAlignItems = 'CENTER';
  runBtn.counterAxisAlignItems = 'CENTER';
  runBtn.appendChild(await txt('Run Code', 14, 'Semi Bold', '#FFFFFF'));
  centerPanel.appendChild(runBtn);

  panels.appendChild(centerPanel);

  // Right panel: Output
  const rightPanel = autoFrame('Output Panel', 'VERTICAL', {
    w: 200, fill: solid('#FAFAFA'), gap: 8, padding: 16,
  });
  rightPanel.primaryAxisSizingMode = 'FIXED';
  rightPanel.counterAxisSizingMode = 'FIXED';
  rightPanel.resize(200, 1366);
  rightPanel.strokes = [{ type: 'SOLID', color: hex('#E5E7EB') }];
  rightPanel.strokeWeight = 1;
  rightPanel.strokeAlign = 'INSIDE';

  rightPanel.appendChild(await txt('Output', 14, 'Semi Bold', '#111827'));

  const outputBox = autoFrame('Output Box', 'VERTICAL', {
    fill: solid('#1E1E1E'), radius: 8, padding: 12, gap: 4,
  });
  outputBox.layoutAlign = 'STRETCH';
  outputBox.appendChild(await txt('> [0, 1]', 13, 'Regular', '#22C55E'));
  outputBox.appendChild(await txt('Runtime: 2ms', 12, 'Regular', '#9CA3AF'));
  rightPanel.appendChild(outputBox);

  rightPanel.appendChild(await txt('Test Cases', 14, 'Semi Bold', '#111827'));
  const testCase = autoFrame('Test Case', 'VERTICAL', {
    fill: solid('#FFFFFF'), radius: 8, padding: 12, gap: 4,
    stroke: '#E5E7EB',
  });
  testCase.layoutAlign = 'STRETCH';
  testCase.appendChild(await txt('Test 1: Passed', 13, 'Semi Bold', '#22C55E'));
  testCase.appendChild(await txt('[2,7,11,15], 9', 12, 'Regular', '#6B7280'));
  rightPanel.appendChild(testCase);

  panels.appendChild(rightPanel);

  screen.appendChild(panels);
  parent.appendChild(screen);
  return screen;
}

async function buildIPadSettings(parent) {
  const screen = autoFrame('iPad \u2014 Settings', 'HORIZONTAL', {
    w: 1024, h: 1366, fill: solid('#FFFFFF'), clip: true, gap: 0,
  });
  screen.primaryAxisSizingMode = 'FIXED';
  screen.counterAxisSizingMode = 'FIXED';
  screen.x = 5620;

  screen.appendChild(await iPadSidebar('Settings'));

  const main = autoFrame('Main', 'VERTICAL', { gap: 24, padding: 32 });
  main.layoutGrow = 1;
  main.layoutAlign = 'STRETCH';
  main.counterAxisAlignItems = 'CENTER';
  main.clipsContent = true;

  // Inner container max-width 600
  const inner = autoFrame('Settings Inner', 'VERTICAL', { gap: 24 });
  inner.resize(600, 1);
  inner.primaryAxisSizingMode = 'AUTO';
  inner.counterAxisSizingMode = 'FIXED';

  inner.appendChild(await txt('Settings', 24, 'Bold', '#111827'));

  async function settingsRow(iconColor, title, subtitle, hasChevron) {
    const row = autoFrame('Row: ' + title, 'HORIZONTAL', { gap: 12, py: 14, px: 0 });
    row.layoutAlign = 'STRETCH';
    row.counterAxisAlignItems = 'CENTER';
    row.appendChild(circle(36, iconColor));
    const info = autoFrame('Info', 'VERTICAL', { gap: 2 });
    info.layoutGrow = 1;
    info.appendChild(await txt(title, 14, 'Regular', '#111827'));
    if (subtitle) info.appendChild(await txt(subtitle, 12, 'Regular', '#6B7280'));
    row.appendChild(info);
    if (hasChevron) row.appendChild(await txt('\u203A', 18, 'Regular', '#9CA3AF'));
    return row;
  }

  // ACCOUNT
  inner.appendChild(await txt('ACCOUNT', 12, 'Medium', '#6B7280'));
  const accCard = autoFrame('Account', 'VERTICAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 0,
    stroke: '#E5E7EB',
  });
  accCard.layoutAlign = 'STRETCH';
  accCard.appendChild(await settingsRow('#F3F4F6', 'Profile', 'Ashim Dahal', true));
  const d1 = rect(568, 1, '#E5E7EB');
  d1.layoutAlign = 'STRETCH';
  accCard.appendChild(d1);
  accCard.appendChild(await settingsRow('#EEF2FF', 'LeetCode Account', 'ashim986', true));
  inner.appendChild(accCard);

  // PREFERENCES
  inner.appendChild(await txt('PREFERENCES', 12, 'Medium', '#6B7280'));
  const prefCard = autoFrame('Preferences', 'VERTICAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 0,
    stroke: '#E5E7EB',
  });
  prefCard.layoutAlign = 'STRETCH';
  prefCard.appendChild(await settingsRow('#FEF3C7', 'Notifications', 'Enabled', true));
  const d2 = rect(568, 1, '#E5E7EB');
  d2.layoutAlign = 'STRETCH';
  prefCard.appendChild(d2);
  prefCard.appendChild(await settingsRow('#F3F4F6', 'Appearance', 'System', true));
  inner.appendChild(prefCard);

  // LEETCODE
  inner.appendChild(await txt('LEETCODE', 12, 'Medium', '#6B7280'));
  const lcCard = autoFrame('LeetCode', 'VERTICAL', {
    fill: solid('#FFFFFF'), radius: 12, padding: 16, gap: 0,
    stroke: '#E5E7EB',
  });
  lcCard.layoutAlign = 'STRETCH';
  lcCard.appendChild(await settingsRow('#DCFCE7', 'Sync Status', 'Up to date', true));
  inner.appendChild(lcCard);

  // Sign Out
  const signOut = autoFrame('Sign Out', 'HORIZONTAL', {
    fill: solid('#FEE2E2'), radius: 12, py: 14, px: 0, gap: 0,
  });
  signOut.layoutAlign = 'STRETCH';
  signOut.primaryAxisAlignItems = 'CENTER';
  signOut.counterAxisAlignItems = 'CENTER';
  signOut.appendChild(await txt('Sign Out', 16, 'Semi Bold', '#DC2626'));
  inner.appendChild(signOut);

  main.appendChild(inner);
  screen.appendChild(main);
  parent.appendChild(screen);
  return screen;
}

// ---------------------------------------------------------------------------
// Main entry point
// ---------------------------------------------------------------------------
async function main() {
  // Load fonts
  await figma.loadFontAsync({ family: 'Inter', style: 'Regular' });
  await figma.loadFontAsync({ family: 'Inter', style: 'Medium' });
  await figma.loadFontAsync({ family: 'Inter', style: 'Semi Bold' });
  await figma.loadFontAsync({ family: 'Inter', style: 'Bold' });

  // ----- iPhone screens -----
  const iphonePage = findOrCreatePage('iPhone design');
  figma.currentPage = iphonePage;

  await buildIPhoneToday(iphonePage);
  await buildIPhonePlan(iphonePage);
  await buildIPhoneStats(iphonePage);
  await buildIPhoneFocus(iphonePage);
  await buildIPhoneCoding(iphonePage);
  await buildIPhoneSettings(iphonePage);

  // ----- iPad screens -----
  const ipadPage = findOrCreatePage('iPad Design');
  figma.currentPage = ipadPage;

  await buildIPadToday(ipadPage);
  await buildIPadPlan(ipadPage);
  await buildIPadStats(ipadPage);
  await buildIPadFocus(ipadPage);
  await buildIPadCoding(ipadPage);
  await buildIPadSettings(ipadPage);

  figma.closePlugin('FocusApp screens generated successfully! 12 screens created.');
}

main();
