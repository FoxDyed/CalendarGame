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

const page = await browser.newPage();
const errors = [];
page.on('console', (m) => { if (m.type() === 'error') errors.push(m.text()); });
await page.goto('http://127.0.0.1:4173', { waitUntil: 'networkidle' });
await page.click('#randomBtn');
await page.click('#hintBtn');
await page.screenshot({ path: '.logs/board.png', fullPage: true });
const debug = await page.textContent('#debug');
fs.writeFileSync('.logs/08_playwright_debug.log', `errors=${errors.length}\n${errors.join('\n')}\n\n${debug}\n`);
await browser.close();
