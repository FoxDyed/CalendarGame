let chromium;
try {
  ({ chromium } = await import('playwright'));
} catch (error) {
  console.log('PLAYWRIGHT_AVAILABLE=0');
  console.log(`reason=playwright package missing: ${error instanceof Error ? error.message : String(error)}`);
  process.exit(0);
}

try {
  const browser = await chromium.launch({ headless: true });
  await browser.close();
  console.log('PLAYWRIGHT_AVAILABLE=1');
  process.exit(0);
} catch (error) {
  console.log('PLAYWRIGHT_AVAILABLE=0');
  console.log(`reason=${error instanceof Error ? error.message : String(error)}`);
  process.exit(0);
}
