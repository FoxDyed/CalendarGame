import { chromium } from 'playwright';
import fs from 'node:fs';

const browser = await chromium.launch({ headless: true });
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
