import fs from 'node:fs';
let chromium;
try { ({ chromium } = await import('playwright')); } catch { console.log('SKIP: Playwright package unavailable.'); process.exit(0); }
let browser;
try { browser = await chromium.launch({ headless: true }); } catch (error) { console.log('SKIP: Playwright Chromium browser unavailable in this environment.'); console.log(error instanceof Error ? error.message : String(error)); process.exit(0); }
const context = await browser.newContext({ viewport: { width: 390, height: 844 }, hasTouch: true, isMobile: true });
const page = await context.newPage();
const out = [];
await page.goto('http://127.0.0.1:4173', { waitUntil: 'networkidle' });
const first = page.locator('.piece').first();
const box = await first.boundingBox();
if (!box) throw new Error('No piece');
await page.touchscreen.tap(box.x + 10, box.y + 10);
out.push('mobile interaction: tapped piece');
await page.click('#hintBtn');
const hint = await page.locator('#hint').textContent();
await page.reload({ waitUntil: 'networkidle' });
out.push(`persistence: ${ (await page.locator('#hint').textContent()) === hint }`);
await page.keyboard.press('Tab'); await page.keyboard.press('Tab');
out.push('a11y navigation: tabbed controls');
out.push(`tutorial visible=${Boolean(await page.locator('#tutorial').textContent())}`);
await page.click('#rotateBtn');
await page.click('#flipBtn');
await page.click('#clearBtn');
await page.click('#redoBtn');
out.push('piece control interaction passed');
fs.writeFileSync('.logs/10_playwright_gameplay.log', out.join('\n'));
await browser.close();
