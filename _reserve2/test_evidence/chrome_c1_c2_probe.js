const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const outDir = 'C:/sources/asp/netcampus/hao/work/_reserve2/test_evidence';
const indexUrl = 'http://localhost:8088/netcampus/hao/work/_reserve2/index.asp';

(async () => {
  const browser = await chromium.connectOverCDP('http://127.0.0.1:9222');
  const page = browser.contexts().flatMap((ctx) => ctx.pages())[0];
  if (!page) throw new Error('No Chrome page found via CDP');

  const result = { startedAt: new Date().toISOString() };

  async function ensureIndex() {
    await page.goto(indexUrl, { waitUntil: 'domcontentloaded' });
    await page.locator('input[name="SelectCourse"][value^="61,"]').waitFor({ state: 'attached', timeout: 10000 });
  }

  await ensureIndex();
  await page.locator('input[name="SelectCourse"][value^="61,"]').check();
  await Promise.all([
    page.waitForURL('**/work/_reserve2/main.asp', { timeout: 10000 }),
    page.locator('button[type="submit"]').click()
  ]);
  await page.locator('.lesson-list').waitFor({ state: 'visible', timeout: 10000 });

  const metaTexts = await page.locator('.lesson-list .lesson-meta').allTextContents();
  result.c2_06 = {
    url: page.url(),
    metaTexts,
    hasTeacherPrefix: metaTexts.some((t) => t.includes('教師名:')),
    hasTeacherValue: metaTexts.some((t) => /教師名:\s*\S+/.test(t)),
    status: metaTexts.some((t) => /教師名:\s*\S+/.test(t)) ? 'pass' : 'fail',
    evidence: 'C2_06_main_chrome_20260617.png'
  };
  await page.screenshot({
    path: path.join(outDir, result.c2_06.evidence),
    fullPage: true
  });

  await ensureIndex();
  const popupPromise = page.context().waitForEvent('page', { timeout: 10000 });
  await page.evaluate((url) => {
    window.open(url, '_blank', 'width=1280,height=1000');
  }, indexUrl);
  const popup = await popupPromise;
  await popup.waitForLoadState('domcontentloaded');
  await popup.locator('a[href="javascript:window.close();"]').waitFor({ state: 'visible', timeout: 10000 });
  await popup.screenshot({
    path: path.join(outDir, 'C1_06_popup_before_close_chrome_20260617.png'),
    fullPage: true
  });
  const closePromise = popup.waitForEvent('close', { timeout: 5000 }).then(() => true).catch(() => false);
  await popup.locator('a[href="javascript:window.close();"]').click();
  const closed = await closePromise;
  result.c1_06 = {
    closed,
    status: closed ? 'pass' : 'not-run',
    evidence: 'C1_06_popup_before_close_chrome_20260617.png'
  };

  result.finishedAt = new Date().toISOString();
  fs.writeFileSync(path.join(outDir, 'chrome_c1_c2_probe_20260617.json'), JSON.stringify(result, null, 2), 'utf8');
  console.log(JSON.stringify(result, null, 2));
  await browser.close();
})().catch((err) => {
  const failure = {
    failedAt: new Date().toISOString(),
    error: String(err && err.stack ? err.stack : err)
  };
  try {
    fs.writeFileSync(path.join(outDir, 'chrome_c1_c2_probe_20260617.error.json'), JSON.stringify(failure, null, 2), 'utf8');
  } catch (_) {}
  console.error(err);
  process.exit(1);
});
