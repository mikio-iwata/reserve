import { firefox } from "playwright";

try {
  const ctx = await firefox.launchPersistentContext("C:/codex_ff_profile", {
    headless: false,
    executablePath: "C:/Program Files/Mozilla Firefox/firefox.exe",
  });
  const page = ctx.pages()[0] || await ctx.newPage();
  await page.goto("http://localhost:8088/netcampus/hao/login_new/index.asp", { waitUntil: "domcontentloaded" });
  console.log(JSON.stringify({ ok: true, urls: ctx.pages().map(p => p.url()) }, null, 2));
} catch (e) {
  console.log(JSON.stringify({ ok: false, error: String(e) }, null, 2));
  process.exitCode = 1;
}
