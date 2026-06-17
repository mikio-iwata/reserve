import fs from "node:fs/promises";
import path from "node:path";
import { chromium, firefox } from "playwright";

const OUT = path.resolve("work/_reserve2/test_evidence/section3_20260617");
await fs.mkdir(OUT, { recursive: true });

const widthsCore = [375, 768, 1280];
const widthsEdge = [320, 900, 1920];
const widthsTap = [375];
const widthsSpecial = [375];
const screens = [
  { key: "index", url: "http://localhost:8088/netcampus/hao/work/_reserve2/index.asp" },
  { key: "main", url: "http://localhost:8088/netcampus/hao/work/_reserve2/main.asp" },
  { key: "reserve_intro", url: "http://localhost:8088/netcampus/hao/work/_reserve2/reserve.asp?School=5221" },
  { key: "reserve_list", url: "http://localhost:8088/netcampus/hao/work/_reserve2/reserve.asp?ClassYear=2026&ClassMonth=6&ClassDate=29&School=5221" },
];

function absRect(r) {
  if (!r) return null;
  return { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height), right: Math.round(r.right), bottom: Math.round(r.bottom) };
}

async function metrics(page) {
  return await page.evaluate(() => {
    const doc = document.documentElement;
    const body = document.body;
    const header = document.querySelector(".site-header img");
    const main = document.querySelector("#main, #mainR, .page-shell");
    const rect = el => {
      if (!el) return null;
      const r = el.getBoundingClientRect();
      return { x: r.x, y: r.y, width: r.width, height: r.height, right: r.right, bottom: r.bottom };
    };
    const headerRect = rect(header);
    const mainRect = rect(main);
    return {
      url: location.href,
      innerWidth: window.innerWidth,
      innerHeight: window.innerHeight,
      scrollWidth: Math.max(doc.scrollWidth, body?.scrollWidth || 0),
      clientWidth: doc.clientWidth,
      headerOverflow: !!(headerRect && mainRect && (headerRect.left < mainRect.left - 1 || headerRect.right > mainRect.right + 1)),
      headerRect,
      mainRect,
      charSet: document.characterSet,
      bodyText: body?.innerText?.slice(0, 200) || "",
      radios: [...document.querySelectorAll('input[type="radio"]')].map(el => ({ value: el.value, checked: el.checked, disabled: el.disabled, rect: el.getBoundingClientRect() })),
      buttons: [...document.querySelectorAll('button,a.btn,input[type="submit"]')].map(el => ({ text: (el.textContent || el.value || "").trim(), rect: el.getBoundingClientRect() })),
      selectRects: [...document.querySelectorAll('select')].map(el => ({ name: el.name, value: el.value, rect: el.getBoundingClientRect() })),
      images: [...document.querySelectorAll('img')].map(el => ({ alt: el.alt, src: el.getAttribute('src'), rect: el.getBoundingClientRect() })),
    };
  });
}

async function gotoAndWait(page, url) {
  await page.goto(url, { waitUntil: "domcontentloaded" });
  await page.waitForLoadState("networkidle").catch(() => {});
}

async function resizeWindow(page, width, height) {
  const client = await page.context().newCDPSession(page);
  const { windowId } = await client.send("Browser.getWindowForTarget");
  await client.send("Browser.setWindowBounds", {
    windowId,
    bounds: { left: 20, top: 20, width, height, windowState: "normal" },
  });
  await page.waitForTimeout(300);
}

async function openMain(page) {
  await gotoAndWait(page, screens[0].url);
  await page.evaluate(() => { const r = document.querySelector('input[value^="61,"]'); if (r) r.checked = true; });
  await Promise.all([
    page.waitForNavigation({ waitUntil: "domcontentloaded" }),
    page.locator("form").evaluate(form => form.submit()),
  ]);
  await page.waitForLoadState("networkidle").catch(() => {});
  if (!page.url().includes("/main.asp")) throw new Error(`main navigation failed: ${page.url()}`);
}

async function openReserveIntro(page) {
  await openMain(page);
  await page.selectOption('select[name="School"]', '5221');
  await Promise.all([
    page.waitForNavigation({ waitUntil: "domcontentloaded" }),
    page.locator("form").nth(0).evaluate(form => form.submit()),
  ]);
  await page.waitForLoadState("networkidle").catch(() => {});
  if (!page.url().includes("/reserve.asp")) throw new Error(`reserve navigation failed: ${page.url()}`);
}

async function openReserveList(page) {
  await openReserveIntro(page);
  await gotoAndWait(page, screens[3].url);
  if (!page.url().includes("/reserve.asp")) throw new Error(`reserve list navigation failed: ${page.url()}`);
}

async function shot(page, browserName, screenKey, width, suffix) {
  const file = path.join(OUT, `${browserName}_${screenKey}_${width}_${suffix}_20260617.png`);
  const client = await page.context().newCDPSession(page);
  const { data } = await client.send("Page.captureScreenshot", { format: "png", fromSurface: true });
  await fs.writeFile(file, Buffer.from(data, "base64"));
  return file;
}

async function runBrowser(browserName, browser) {
  const context = browser.contexts()[0];
  let page = context.pages().find(p => p.url().includes("localhost:8088/netcampus/hao/work/_reserve2"));
  if (!page) {
    page = context.pages().find(p => p.url().startsWith("http"));
  }
  if (!page) {
    page = await context.newPage();
  }
  const results = [];

  // core widths
  for (const width of widthsCore) {
    await resizeWindow(page, width, 900);
    await openMain(page);
    let m = await metrics(page);
    const mainShot = await shot(page, browserName, "main", width, "core");
    results.push({ browserName, screen: "main", width, phase: "core", metrics: m, shot: mainShot });

    await openReserveIntro(page);
    m = await metrics(page);
    const reserveIntroShot = await shot(page, browserName, "reserve_intro", width, "core");
    results.push({ browserName, screen: "reserve_intro", width, phase: "core", metrics: m, shot: reserveIntroShot });

    await openReserveList(page);
    m = await metrics(page);
    const reserveListShot = await shot(page, browserName, "reserve_list", width, "core");
    results.push({ browserName, screen: "reserve_list", width, phase: "core", metrics: m, shot: reserveListShot });
  }

  // edge widths
  for (const width of widthsEdge) {
    await resizeWindow(page, width, 900);
    await openMain(page);
    let m = await metrics(page);
    results.push({ browserName, screen: "main", width, phase: "edge", metrics: m, shot: await shot(page, browserName, "main", width, "edge") });
    await openReserveIntro(page);
    m = await metrics(page);
    results.push({ browserName, screen: "reserve_intro", width, phase: "edge", metrics: m, shot: await shot(page, browserName, "reserve_intro", width, "edge") });
    await openReserveList(page);
    m = await metrics(page);
    results.push({ browserName, screen: "reserve_list", width, phase: "edge", metrics: m, shot: await shot(page, browserName, "reserve_list", width, "edge") });
  }

  // tap targets
  for (const width of widthsTap) {
    await resizeWindow(page, width, 900);
    await openMain(page);
    results.push({ browserName, screen: "main", width, phase: "tap", metrics: await metrics(page), shot: await shot(page, browserName, "main", width, "tap") });
    await openReserveList(page);
    results.push({ browserName, screen: "reserve_list", width, phase: "tap", metrics: await metrics(page), shot: await shot(page, browserName, "reserve_list", width, "tap") });
  }

  // specials chrome-only later
  return results;
}

const all = [];
const mode = (process.argv[2] || "all").toLowerCase();
if (mode === "all" || mode === "chrome") {
  const chrome = await chromium.connectOverCDP("http://127.0.0.1:9222");
  all.push(...await runBrowser("chrome", chrome));
}
if (mode === "all" || mode === "edge") {
  const edge = await chromium.connectOverCDP("http://127.0.0.1:9223");
  all.push(...await runBrowser("edge", edge));
}

let firefoxStatus = { status: "not_run" };
if (mode === "all" || mode === "firefox") {
  try {
    const ff = await firefox.launchPersistentContext("C:/codex_ff_profile", {
      headless: false,
      executablePath: "C:/Program Files/Mozilla Firefox/firefox.exe",
    });
    const ffPage = ff.pages()[0] || await ff.newPage();
    await ffPage.goto(screens[0].url, { waitUntil: "domcontentloaded" });
    firefoxStatus = { status: "launched", pages: ff.pages().map(p => p.url()) };
    await ff.close();
  } catch (e) {
    firefoxStatus = { status: "failed", error: String(e) };
  }
}

const outName = mode === "all" ? "section3_results.json" : `section3_results_${mode}.json`;
await fs.writeFile(path.join(OUT, outName), JSON.stringify({ all, firefoxStatus, mode }, null, 2), "utf8");
console.log(JSON.stringify({ count: all.length, firefoxStatus, mode }, null, 2));
