import fs from 'node:fs';

let chromium;
try {
  ({ chromium } = await import('playwright'));
} catch (error) {
  console.log('SKIP: Playwright package unavailable in this environment.');
  console.log(error instanceof Error ? error.message : String(error));
  process.exit(0);
}

let browser;
try {
  browser = await chromium.launch({ headless: true });
} catch (error) {
  console.log('SKIP: Playwright Chromium browser unavailable in this environment.');
  console.log(error instanceof Error ? error.message : String(error));
  process.exit(0);
}

const log = [];
const viewports = [
  { name: 'mobile-portrait', viewport: { width: 390, height: 844 }, dpr: 3, hasTouch: true },
  { name: 'mobile-landscape', viewport: { width: 844, height: 390 }, dpr: 3, hasTouch: true },
  { name: 'desktop', viewport: { width: 1280, height: 800 }, dpr: 2, hasTouch: false }
];

for (const cfg of viewports) {
  const context = await browser.newContext({
    viewport: cfg.viewport,
    deviceScaleFactor: cfg.dpr,
    hasTouch: cfg.hasTouch,
    isMobile: cfg.hasTouch
  });
  const page = await context.newPage();
  await page.goto('http://127.0.0.1:4173', { waitUntil: 'networkidle' });

  const piece = page.locator('.piece').first();
  const box = await piece.boundingBox();
  if (!box) throw new Error(`missing piece in ${cfg.name}`);

  if (cfg.hasTouch) {
    await page.touchscreen.tap(box.x + box.width / 2, box.y + box.height / 2);
    await page.touchscreen.tap(box.x + box.width / 2 + 40, box.y + box.height / 2);
  }

  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
  await page.mouse.down();
  await page.mouse.move(box.x + box.width / 2 + 40, box.y + box.height / 2, { steps: 8 });
  await page.mouse.up();

  const board = await page.locator('#board').boundingBox();
  log.push(`${cfg.name}: board=${Math.round(board.width)}x${Math.round(board.height)} dpr=${cfg.dpr}`);
  await page.screenshot({ path: `.logs/render-${cfg.name}.png`, fullPage: true });
  await context.close();
}

fs.writeFileSync('.logs/09_playwright_rendering.log', log.join('\n') + '\n');
await browser.close();
