const fs = require("node:fs");
const fsp = require("node:fs/promises");
const path = require("node:path");
const { firefox } = require("C:/codex_pw/node_modules/playwright");

const profileDir = "C:/codex_ff_profile_run2";
const outputDir = "C:/sources/asp/netcampus/hao/work/_reserve2/test_evidence";
const loginUrl = "http://localhost:8088/netcampus/hao/login_new/login2.asp";
const reserveRootUrl = "http://localhost:8088/netcampus/hao/work/_reserve2/";
const indexUrl = `${reserveRootUrl}index.asp`;
const metricsPath = path.join(outputDir, "firefox_loggedin_metrics_20260615.json");
const statePath = path.join(outputDir, "firefox_login_state_20260615.json");
const executablePath = "C:/codex_pw/node_modules/playwright-core/.local-browsers/firefox-1522/firefox/firefox.exe";

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function writeState(state) {
  await fsp.writeFile(statePath, JSON.stringify(state, null, 2), "utf8");
}

async function captureMetrics(page, label) {
  return page.evaluate((currentLabel) => {
    const header = document.querySelector(".site-header");
    const rect = header ? header.getBoundingClientRect() : null;
    return {
      label: currentLabel,
      url: location.href,
      innerWidth: window.innerWidth,
      innerHeight: window.innerHeight,
      scrollWidth: document.documentElement.scrollWidth,
      scrollHeight: document.documentElement.scrollHeight,
      headerRect: rect
        ? {
            x: rect.x,
            y: rect.y,
            width: rect.width,
            height: rect.height,
            right: rect.right,
          }
        : null,
      headerOverflow: rect ? rect.right > window.innerWidth + 0.5 : null,
      bodyPreview: (document.body.innerText || "").replace(/\s+/g, " ").trim().slice(0, 200),
    };
  }, label);
}

async function capture(page, name, width, height, metrics) {
  await page.setViewportSize({ width, height });
  await page.waitForLoadState("domcontentloaded");
  const metric = await captureMetrics(page, name.replace(/\.png$/, ""));
  metrics.push(metric);
  const filePath = path.join(outputDir, name);
  await page.screenshot({ path: filePath, fullPage: true });
}

async function waitForHumanLogin(context, page) {
  await writeState({
    stage: "waiting_for_login",
    message: "Firefox window is open. Please log in with the test account.",
    loginUrl,
    timestamp: new Date().toISOString(),
  });

  const timeoutAt = Date.now() + 15 * 60 * 1000;
  while (Date.now() < timeoutAt) {
    const pages = context.pages();
    const targetPage = pages.find((candidate) => candidate.url().startsWith(reserveRootUrl));
    if (targetPage) {
      await writeState({
        stage: "login_detected",
        url: targetPage.url(),
        timestamp: new Date().toISOString(),
      });
      return targetPage;
    }
    await sleep(1000);
  }
  throw new Error("Timed out waiting for human login.");
}

async function ensureIndex(page) {
  if (!page.url().startsWith(indexUrl)) {
    await page.goto(indexUrl, { waitUntil: "domcontentloaded" });
  }
  if (page.url().includes("/error.asp")) {
    throw new Error("Session expired before testing. Re-login required.");
  }
}

async function selectFirstCourse(page) {
  const radio = page.locator('input[type="radio"]').first();
  await radio.check();
}

async function goToMain(page) {
  await Promise.all([
    page.waitForURL("**/main.asp*", { timeout: 15000 }),
    page.locator('form[action="index.asp"]').evaluate((form) => form.submit()),
  ]);
}

async function goToReserve(page) {
  await page.locator("#School").selectOption("5221");
  await Promise.all([
    page.waitForURL("**/reserve.asp*", { timeout: 15000 }),
    page.locator('input[name="Action"][value="Reserve"]').evaluate((input) => {
      input.form.submit();
    }),
  ]);
}

async function main() {
  await fsp.mkdir(profileDir, { recursive: true });
  await fsp.mkdir(outputDir, { recursive: true });

  const context = await firefox.launchPersistentContext(profileDir, {
    headless: false,
    executablePath,
    viewport: { width: 1280, height: 900 },
    acceptDownloads: false,
  });

  try {
    const page = context.pages()[0] || (await context.newPage());
    await page.goto(loginUrl, { waitUntil: "domcontentloaded" });
    const targetPage = await waitForHumanLogin(context, page);
    await ensureIndex(targetPage);

    const metrics = [];

    await capture(targetPage, "A_index_WinFirefox_375_20260615.png", 375, 900, metrics);
    await capture(targetPage, "A_index_WinFirefox_1280_20260615.png", 1280, 900, metrics);

    await targetPage.setViewportSize({ width: 1280, height: 900 });
    await selectFirstCourse(targetPage);
    await goToMain(targetPage);
    if (targetPage.url().includes("/error.asp")) {
      throw new Error("Moved to error.asp after index -> main. Session or selection issue.");
    }

    await capture(targetPage, "A_main_WinFirefox_375_20260615.png", 375, 1100, metrics);
    await capture(targetPage, "A_main_WinFirefox_1280_20260615.png", 1280, 1100, metrics);

    await targetPage.setViewportSize({ width: 1280, height: 1100 });
    await goToReserve(targetPage);
    if (targetPage.url().includes("/error.asp")) {
      throw new Error("Moved to error.asp after main -> reserve. Session issue.");
    }

    await capture(targetPage, "A_reserve_WinFirefox_375_20260615.png", 375, 1200, metrics);
    await capture(targetPage, "A_reserve_WinFirefox_1280_20260615.png", 1280, 1200, metrics);

    await fsp.writeFile(metricsPath, JSON.stringify(metrics, null, 2), "utf8");
    await writeState({
      stage: "completed",
      metricsPath,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    await writeState({
      stage: "failed",
      message: error.message,
      timestamp: new Date().toISOString(),
    });
    throw error;
  } finally {
    await context.close();
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
