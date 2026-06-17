const fs = require('fs');
const path = require('path');
const { firefox } = require('playwright');

const outDir = 'C:/sources/asp/netcampus/hao/work/_reserve2/test_evidence';
const loginUrl = 'http://localhost:8088/netcampus/hao/login_new/login2.asp';
const indexUrl = 'http://localhost:8088/netcampus/hao/work/_reserve2/index.asp';
const profileDir = 'C:/codex_ff_profile';

function writeJson(name, value) {
  fs.writeFileSync(path.join(outDir, name), JSON.stringify(value, null, 2), 'utf8');
}

(async () => {
  const result = {
    startedAt: new Date().toISOString(),
    c2_06: { status: 'not-run' },
    c1_06: { status: 'not-run' }
  };

  const context = await firefox.launchPersistentContext(profileDir, {
    headless: false,
    viewport: { width: 1280, height: 1400 }
  });

  const page = context.pages()[0] || await context.newPage();
  await page.goto(loginUrl, { waitUntil: 'domcontentloaded' });
  console.log('FIREFOX_C1_C2_LOGIN_READY');

  const deadline = Date.now() + 10 * 60 * 1000;
  while (Date.now() < deadline) {
    const onIndex = page.url().includes('/work/_reserve2/index.asp');
    const courseRadioCount = await page.locator('input[name="SelectCourse"][value^="61,"]').count().catch(() => 0);
    if (onIndex && courseRadioCount > 0) break;
    await page.waitForTimeout(2000);
  }

  const loginReady = page.url().includes('/work/_reserve2/index.asp') &&
    await page.locator('input[name="SelectCourse"][value^="61,"]').count() > 0;

  if (!loginReady) {
    throw new Error('Login/index page was not detected within 10 minutes');
  }

  async function gotoCourse61Main() {
    await page.goto(indexUrl, { waitUntil: 'domcontentloaded' });
    await page.locator('input[name="SelectCourse"][value^="61,"]').waitFor({ state: 'attached', timeout: 10000 });
    await page.locator('input[name="SelectCourse"][value^="61,"]').check();
    await Promise.all([
      page.waitForURL('**/work/_reserve2/main.asp', { timeout: 10000 }),
      page.locator('button[type="submit"]').click()
    ]);
    await page.locator('.lesson-list, select[name="School"]').first().waitFor({ state: 'visible', timeout: 10000 });
  }

  // C2-06: CourseType=1 reserved list should render teacher name.
  await gotoCourse61Main();
  const lessonMetaTexts = await page.locator('.lesson-list .lesson-meta').allTextContents();
  result.c2_06.metaTexts = lessonMetaTexts;
  result.c2_06.url = page.url();
  result.c2_06.hasTeacherPrefix = lessonMetaTexts.some((t) => t.includes('教師名:'));
  result.c2_06.hasTeacherValue = lessonMetaTexts.some((t) => /教師名:\s*\S+/.test(t));
  await page.screenshot({
    path: path.join(outDir, 'C2_06_main_firefox_20260617.png'),
    fullPage: true
  });
  result.c2_06.evidence = 'C2_06_main_firefox_20260617.png';
  result.c2_06.status = result.c2_06.hasTeacherValue ? 'pass' : 'fail';

  // C1-06: close button should close a script-opened popup.
  const popupPromise = context.waitForEvent('page', { timeout: 10000 });
  await page.evaluate((url) => {
    window.open(url, '_blank', 'width=1280,height=1400');
  }, indexUrl);
  const popup = await popupPromise;
  await popup.waitForLoadState('domcontentloaded');
  await popup.locator('a[href="javascript:window.close();"]').waitFor({ state: 'visible', timeout: 10000 });
  await popup.screenshot({
    path: path.join(outDir, 'C1_06_popup_before_close_firefox_20260617.png'),
    fullPage: true
  });
  const closePromise = popup.waitForEvent('close', { timeout: 5000 }).then(() => true).catch(() => false);
  await popup.locator('a[href="javascript:window.close();"]').click();
  const closed = await closePromise;
  result.c1_06.closed = closed;
  result.c1_06.evidence = 'C1_06_popup_before_close_firefox_20260617.png';
  result.c1_06.status = closed ? 'pass' : 'not-run';

  result.finishedAt = new Date().toISOString();
  writeJson('firefox_c1_c2_probe_20260617.json', result);
  await context.close();
  console.log('FIREFOX_C1_C2_DONE');
})().catch((err) => {
  const failure = {
    failedAt: new Date().toISOString(),
    error: String(err && err.stack ? err.stack : err)
  };
  try {
    writeJson('firefox_c1_c2_probe_20260617.error.json', failure);
  } catch (_) {
    // ignore
  }
  console.error(err);
  process.exit(1);
});
