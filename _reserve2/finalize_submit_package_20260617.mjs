import fs from "node:fs/promises";
import path from "node:path";
import { existsSync } from "node:fs";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const root = "C:/sources/asp/netcampus/hao/work/_reserve2";
const workbookPath = path.join(root, "予約システム_レスポンシブ対応_テスト仕様書.xlsx");
const evidenceRoot = path.join(root, "test_evidence");
const section3Root = path.join(evidenceRoot, "section3_20260617");
const reportDir = path.join(root, "reports", "reserve2", "latest");

await fs.mkdir(reportDir, { recursive: true });

const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(workbookPath));
const sheetA = workbook.worksheets.getItem("A_表示・レスポンシブ");
const sheetC = workbook.worksheets.getItem("C_機能回帰");
const sheetBug = workbook.worksheets.getItem("不具合一覧");

function setCell(sheet, addr, value) {
  sheet.getRange(addr).values = [[value]];
}

function setRowValues(sheet, row, valuesByCol) {
  for (const [col, value] of Object.entries(valuesByCol)) {
    setCell(sheet, `${col}${row}`, value);
  }
}

const aUpdates = {
  55: {
    I: "Edge 実機で 375px 表示を確認。ヘッダー画像はコンテナ幅内に収まり、画面幅を突き破らない。evidence: A_index_WinEdge_375_20260615.png / edge_loggedin_metrics_20260615.json",
    J: "Codex",
  },
  56: {
    I: "Edge 実機で 375px 表示を確認。パンくずは 2 行で自然に折り返し、重なりなし。evidence: A_index_WinEdge_375_20260615.png",
    J: "Codex",
  },
  57: {
    I: "Edge 実機で 375px / 1280px 表示を確認。ボタン列のはみ出しや崩れなし。evidence: A_index_WinEdge_375_20260615.png / A_index_WinEdge_1280_20260615.png",
    J: "Codex",
  },
  61: {
    I: "Edge 実機で 375px / 1280px 表示を確認。Shift_JIS の日本語表示に文字化けなし。evidence: A_index_WinEdge_375_20260615.png / A_index_WinEdge_1280_20260615.png",
    J: "Codex",
  },
  144: {
    H: "合格",
    I: "Firefox 既存証跡で 320/375/768/1024/1280/1920px の error.asp 表示を確認。レイアウト崩れ・要素重なりなし。evidence: A_error_WinFirefox_320.png / A_error_WinFirefox_375.png / A_error_WinFirefox_768.png / A_error_WinFirefox_1024.png / A_error_WinFirefox_1280.png / A_error_WinFirefox_1920.png",
    J: "Codex",
  },
  145: {
    H: "合格",
    I: "Firefox 既存証跡で 320/375/768/1024/1280/1920px の error.asp を確認。意図しない横スクロールなし。evidence: A_error_WinFirefox_320.png / A_error_WinFirefox_375.png / A_error_WinFirefox_768.png / A_error_WinFirefox_1024.png / A_error_WinFirefox_1280.png / A_error_WinFirefox_1920.png",
    J: "Codex",
  },
  146: {
    H: "合格",
    I: "Firefox 768px / 900px のヘッダー矩形確認で imageExceedsHeader=false。375px / 1280px の表示も問題なし。evidence: bugfix_metrics_20260615.json / A_error_WinFirefox_375.png / A_error_WinFirefox_1280.png",
    J: "Codex",
  },
  147: {
    H: "合格",
    I: "Firefox 375px / 1280px の error.asp で action-row のボタン配置に崩れなし。evidence: A_error_WinFirefox_375.png / A_error_WinFirefox_1280.png",
    J: "Codex",
  },
  148: {
    H: "保留",
    I: "Firefox の error.asp について 44px 以上のタップターゲット実測証跡が不足しているため保留。既存スクリーンショットのみでは客先提出根拠として弱い。",
    J: "Codex",
  },
  149: {
    H: "合格",
    I: "Firefox 回転証跡で 375x667 / 667x375 ともに error.asp のレイアウト維持を確認。evidence: A_error_WinFirefox_rotate_375x667.png / A_error_WinFirefox_rotate_667x375.png",
    J: "Codex",
  },
  150: {
    H: "合格",
    I: "Firefox 200% zoom 証跡でテキストの重なり・見切れなし。evidence: A_error_WinFirefox_zoom200.png",
    J: "Codex",
  },
  151: {
    H: "合格",
    I: "Firefox codepage 証跡で Shift_JIS 日本語表示に文字化けなし。evidence: A_error_WinFirefox_codepage_375.png",
    J: "Codex",
  },
  154: {
    H: "合格",
    I: "Firefox images disabled 証跡で alt テキスト表示を確認。evidence: A_error_WinFirefox_imagesDisabled_375.png",
    J: "Codex",
  },
};

const cUpdates = {
  5: {
    F: "Codex IAB / 375・1280",
    H: "index.asp で 2 コース（オンラインレッスン＆WEBセミナー / オンラインチャイナ）のラジオ一覧を表示確認。evidence: C1_index_initial_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  6: {
    F: "Codex IAB / 375・1280",
    H: "コース未選択で次へ押下後、error.asp に「コースが選択されていません。」を表示確認。evidence: C1_04_after_timeout_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  7: {
    F: "Codex IAB / 375・1280",
    H: "オンラインレッスン＆WEBセミナー選択後、main.asp への遷移とセッション保持を確認。evidence: C1_05_to_main_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  8: {
    F: "Win Chrome popup / 375・1280",
    H: "script-opened popup で index.asp を開き、閉じる押下で window.close() により popup が閉じることを Chrome 実機で確認。evidence: C1_06_popup_before_close_chrome_20260617.png / chrome_c1_c2_probe_20260617.json",
    I: "Codex",
    J: "2026/06/17",
  },
  10: {
    F: "Codex IAB / 375・1280",
    H: "残り 17 回の表示と学校 select の表示を確認。evidence: C1_05_to_main_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  12: {
    F: "Codex IAB / 375・1280",
    H: "学校未選択で予約操作後、error.asp に「学校名が選択されていないようです。」を表示確認。evidence: C2_03_no_school_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  13: {
    F: "Codex IAB / 375・1280",
    H: "学校選択後、reserve.asp?School=5221 への遷移を確認。evidence: C2_04_to_reserve_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  14: {
    F: "Codex IAB / 375・1280",
    H: "予約後に main.asp へ戻った際、ハオオンライン校が selected のまま保持されることを確認。evidence: C2_main_after_reserve_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  15: {
    F: "Win Chrome / 375・1280",
    H: "現行アカウントでは CourseType=1 の予約済み UI 証跡を取得できず未実施。course 77 は予約済み対象データがそろわず、course 61 は CourseType=2。evidence: C2_06_main_chrome_20260617.png / teacher_join_probe.asp / scenario_probe.asp / chrome_c1_c2_probe_20260617.json",
    I: "Codex",
    J: "2026/06/17",
  },
  16: {
    F: "Codex IAB / 375・1280",
    G: "保留",
    H: "CourseType=2 セッションでキャンセル一覧を表示したところ、時刻は出るが text_name / lesson_name は空欄だった。改修起因の不具合とは断定せず、対象マスタデータ不足による LEFT JOIN 結果空欄として保留扱い。evidence: C2_main_after_reserve_20260615.png / runtime_regression_notes_20260615.txt",
    I: "Codex",
    J: "2026/06/17",
  },
  18: {
    F: "Codex IAB / 375・1280",
    H: "キャンセル対象未選択で操作後、error.asp に「キャンセルするクラスが選択されていないようです。」を表示確認。evidence: C2_09_no_cancel_selection_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  19: {
    F: "Codex IAB / 375・1280",
    H: "12:00〜12:50 をキャンセル後、残回数が 16→17 に戻ることと DB 値の復元を確認。evidence: C2_10_cancel_done_20260615.png / runtime_regression_notes_20260615.txt",
    I: "Codex",
    J: "2026/06/15",
  },
  20: {
    F: "Codex IAB / 375・1280",
    H: "CourseNumber=2 の条件で戻るボタン表示を確認。evidence: C1_05_to_main_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  22: {
    F: "Codex IAB / 375・1280",
    H: "reserve.asp 初期表示で「日付を選択してください」を確認。evidence: C2_04_to_reserve_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  23: {
    F: "Codex IAB / 375・1280",
    H: "2026/07/01 へ月送りし、July カレンダーの再描画を確認。evidence: C3_02_C3_06_july_no_class_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  24: {
    F: "Codex IAB / 375・1280",
    H: "2026/06/29 の日付選択後、その日のクラス一覧表示を確認。evidence: C3_03_click_date_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  25: {
    F: "Win Edge / 375・1280",
    G: "保留",
    H: "calendar.js 上で canow 付与ロジックは確認したが、実画面の当日セル証跡が無いため保留。",
    I: "Codex",
    J: "2026/06/17",
  },
  26: {
    F: "Win Edge / 375・1280",
    G: "保留",
    H: "calendar.js 上でうるう年判定ロジックは確認したが、2/29 の実画面証跡が無いため保留。",
    I: "Codex",
    J: "2026/06/17",
  },
  27: {
    F: "Codex IAB / 375・1280",
    H: "2026/07/01 で「該当日の開講予定クラスはありません。」を確認。evidence: C3_02_C3_06_july_no_class_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  28: {
    F: "Codex IAB / 375・1280",
    H: "2026/06/29 12:00〜12:50 が「予約可能」でラジオ有効であることを確認。evidence: C3_03_click_date_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  31: {
    F: "Codex IAB / 375・1280",
    H: "2026/06/29 14:00〜14:50 が「予約済」でラジオ無効であることを確認。evidence: C3_03_click_date_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  33: {
    F: "Codex IAB / 375・1280",
    H: "予約対象未選択で操作後、error.asp に「予約するクラスが選択されていないようです。」を表示確認。evidence: C3_12_no_reserve_selection_20260615.png",
    I: "Codex",
    J: "2026/06/15",
  },
  34: {
    F: "Codex IAB / 375・1280",
    H: "12:00〜12:50 を予約後、成功メッセージ表示と DB 値変化を確認。evidence: C3_13_reserved_20260615.png / runtime_regression_notes_20260615.txt",
    I: "Codex",
    J: "2026/06/15",
  },
  35: {
    F: "Win Edge / 375・1280",
    G: "保留",
    H: "ChkSecXss 経由のコード確認はできたが、特殊文字を含む実データ表示証跡が無いため保留。",
    I: "Codex",
    J: "2026/06/17",
  },
  37: {
    F: "Win Edge / 375・1280",
    G: "保留",
    H: "error.asp?Message=... の表示確認メモはあるが、提出用スクリーンショット証跡が残っていないため保留。",
    I: "Codex",
    J: "2026/06/17",
  },
  38: {
    F: "Win Edge / 375・1280",
    G: "保留",
    H: "error.asp の戻る/閉じるのコード確認はあるが、提出用の操作証跡が無いため保留。",
    I: "Codex",
    J: "2026/06/17",
  },
};

const bugUpdates = {
  32: {
    E: "CourseType=2 のキャンセル一覧で text_name / lesson_name が空になる。改修起因ではなく、対象データ不足により LEFT JOIN 結果が NULL/空欄になっている。",
    H: "データ不足",
    I: "コード回帰ではなくデータ不足と切り分け済み。修正対象外。C2-07 は保留扱い。",
    J: "2026/06/15 原因切り分け完了。元版でも同系統の JOIN 構造で、対象データは text_name / lesson_name が空欄。evidence: C2_main_after_reserve_20260615.png / runtime_regression_notes_20260615.txt",
  },
};

for (const [row, values] of Object.entries(aUpdates)) setRowValues(sheetA, row, values);
for (const [row, values] of Object.entries(cUpdates)) setRowValues(sheetC, row, values);
for (const [row, values] of Object.entries(bugUpdates)) setRowValues(sheetBug, row, values);

const exported = await SpreadsheetFile.exportXlsx(workbook);
await fs.writeFile(workbookPath, exported.data);

function extractEvidence(text) {
  const src = String(text ?? "");
  const names = [...src.matchAll(/([A-Za-z0-9_./\\?=&:-]+\.(?:png|json|txt|md|log|asp|html))/g)].map((m) => m[1]);
  const resolved = [];
  for (const rawName of names) {
    const normalized = rawName.replace(/\//g, "\\");
    const base = path.basename(normalized);
    const candidates = [
      path.join(evidenceRoot, normalized),
      path.join(evidenceRoot, base),
      path.join(section3Root, base),
    ];
    for (const candidate of candidates) {
      if (existsSync(candidate)) {
        resolved.push(candidate);
        break;
      }
    }
  }
  return [...new Set(resolved)];
}

function collectRows() {
  const aRows = sheetA.getUsedRange().values.slice(1).filter((row) => row[0]);
  const cRows = sheetC
    .getUsedRange()
    .values.slice(2)
    .filter((row) => /^C\d-\d+$/.test(String(row[0] ?? "")));
  const bugRows = sheetBug.getUsedRange().values.slice(1).filter((row) => row[0]);

  const aItems = aRows.map((row) => ({
    sheet: "A",
    id: row[0],
    browser: row[1],
    screen: row[2],
    page: row[3],
    item: row[4],
    status: row[7],
    memo: row[8] ?? "",
    evidence: extractEvidence(row[8]),
  }));

  const cItems = cRows.map((row) => ({
    sheet: "C",
    id: row[0],
    page: row[1],
    caseName: row[2],
    expected: row[3],
    viewport: row[4],
    browser: row[5],
    status: row[6],
    memo: row[7] ?? "",
    evidence: extractEvidence(row[7]),
  }));

  const bugItems = bugRows.map((row) => ({
    sheet: "BUG",
    id: row[0],
    related: row[1],
    page: row[2],
    status: row[7],
    memo: `${row[8] ?? ""} ${row[9] ?? ""}`.trim(),
    evidence: extractEvidence(`${row[8] ?? ""} ${row[9] ?? ""}`),
  }));

  return { aItems, cItems, bugItems };
}

function tally(items, statusKey = "status") {
  return items.reduce((acc, item) => {
    const key = item[statusKey];
    acc[key] = (acc[key] ?? 0) + 1;
    return acc;
  }, {});
}

function reasonCategoryA(item) {
  if (item.status === "対象外") return "対象外";
  if (item.status === "保留") return "証跡不足";
  if (item.status === "未実施" && item.memo.includes("Failed to launch")) return "実行条件不足(Firefox起動)";
  if (item.status === "未実施") return "未実施";
  return "";
}

function reasonCategoryC(item) {
  const dataShort = new Set(["C1-01", "C1-02", "C2-02", "C2-08", "C3-08", "C3-09", "C3-11"]);
  const execShort = new Set(["C2-06"]);
  if (item.status === "保留" && item.id === "C2-07") return "データ不足(BUG-005)";
  if (item.status === "保留") return "証跡不足";
  if (item.status === "未実施" && dataShort.has(item.id)) return "テストデータ不足";
  if (item.status === "未実施" && execShort.has(item.id)) return "実行条件不足";
  if (item.status === "未実施") return "未実施";
  return "";
}

function rel(file) {
  return path.relative(root, file).replace(/\\/g, "/");
}

const { aItems, cItems, bugItems } = collectRows();
const aCounts = tally(aItems);
const cCounts = tally(cItems);
const bugCounts = tally(bugItems);

const aReasonCounts = {};
for (const item of aItems) {
  const reason = reasonCategoryA(item);
  if (reason) aReasonCounts[reason] = (aReasonCounts[reason] ?? 0) + 1;
}

const cReasonCounts = {};
for (const item of cItems) {
  const reason = reasonCategoryC(item);
  if (reason) cReasonCounts[reason] = (cReasonCounts[reason] ?? 0) + 1;
}

const clientAttention = [
  ...aItems.filter((item) => item.status === "保留" || item.status === "未実施"),
  ...cItems.filter((item) => item.status === "保留" || item.status === "未実施"),
];

const testSummaryMd = [
  "# _reserve2 提出用テストサマリー",
  "",
  "## 実行日",
  "- 2026-06-15〜2026-06-17",
  "",
  "## 対象環境",
  "- IIS ローカル環境",
  "- ルート: `C:/sources/asp/netcampus/hao/work/_reserve2`",
  "",
  "## 対象URL",
  "- `http://localhost:8088/netcampus/hao/work/_reserve2/index.asp`",
  "- `http://localhost:8088/netcampus/hao/work/_reserve2/main.asp`",
  "- `http://localhost:8088/netcampus/hao/work/_reserve2/reserve.asp`",
  "- `http://localhost:8088/netcampus/hao/work/_reserve2/error.asp`",
  "",
  "## 対象ブラウザ",
  "- Win Chrome",
  "- Win Edge",
  "- Win Firefox",
  "",
  "## 証跡フォルダー",
  `- \`${evidenceRoot}\``,
  "",
  "## 最終件数",
  `- A_表示・レスポンシブ: 合格 ${aCounts["合格"] ?? 0} / 保留 ${aCounts["保留"] ?? 0} / 未実施 ${aCounts["未実施"] ?? 0} / 対象外 ${aCounts["対象外"] ?? 0}`,
  `- C_機能回帰: 合格 ${cCounts["合格"] ?? 0} / 保留 ${cCounts["保留"] ?? 0} / 不合格 ${cCounts["不合格"] ?? 0} / 未実施 ${cCounts["未実施"] ?? 0}`,
  `- 不具合一覧: 対応済み ${bugCounts["対応済"] ?? 0} / データ不足 ${bugCounts["データ不足"] ?? 0} / 本番確認待ち ${bugCounts["本番確認待ち"] ?? 0}`,
  "",
  "## 対象外188件の説明",
  "- A_表示・レスポンシブのうち、チェックリスト セクション5 で対象外と整理した細粒度の幅総当たり、実機外条件、重複観点を対象外 188 件として確定した。",
  "",
  "## 未実施・保留の理由別内訳",
  ...Object.entries(aReasonCounts).map(([k, v]) => `- A: ${k} ${v}件`),
  ...Object.entries(cReasonCounts).map(([k, v]) => `- C: ${k} ${v}件`),
  "",
  "## 不合格または保留の一覧",
  ...clientAttention.map((item) => `- ${item.id}: ${item.status} / ${item.memo}`),
  "",
  "## 客先提出時の注意点",
  "- 証跡が無い項目は合格にせず、保留または未実施のまま残した。",
  "- C2-07 / BUG-005 は改修起因の不具合ではなく、対象データ不足による LEFT JOIN 結果空欄として整理した。",
  "- BUG-006 は D:\\Inetpub\\haolog の環境差異が前提であり、本番相当環境での確認が残っている。",
  "",
  "## 次に確認が必要な最小項目",
  "- A-147: Firefox error.asp のタップターゲット 44px 実測",
  "- C3-04: 当日セル強調の実画面証跡",
  "- C3-05: うるう年 2/29 の実画面証跡",
  "- C3-14: 特殊文字を含む実データ表示証跡",
  "- C4-01 / C4-02: error.asp の表示・操作スクリーンショット",
  "- C1-01, C1-02, C2-02, C2-06, C2-08, C3-08, C3-09, C3-11: テストデータまたは実行条件の準備",
  "- BUG-006: 本番相当環境でのログ出力確認",
  "",
].join("\n");

const testSummaryCsvRows = [
  ["section", "metric", "value", "note"],
  ["A", "合格", String(aCounts["合格"] ?? 0), ""],
  ["A", "保留", String(aCounts["保留"] ?? 0), ""],
  ["A", "未実施", String(aCounts["未実施"] ?? 0), ""],
  ["A", "対象外", String(aCounts["対象外"] ?? 0), "セクション5対象外を含む"],
  ["C", "合格", String(cCounts["合格"] ?? 0), ""],
  ["C", "保留", String(cCounts["保留"] ?? 0), ""],
  ["C", "不合格", String(cCounts["不合格"] ?? 0), ""],
  ["C", "未実施", String(cCounts["未実施"] ?? 0), ""],
  ["BUG", "対応済み", String(bugCounts["対応済"] ?? 0), ""],
  ["BUG", "データ不足", String(bugCounts["データ不足"] ?? 0), ""],
  ["BUG", "本番確認待ち", String(bugCounts["本番確認待ち"] ?? 0), ""],
  [],
  ["open_items", "id", "status", "memo"],
  ...clientAttention.map((item) => [item.sheet, item.id, item.status, item.memo]),
];

const allItems = [...aItems, ...cItems, ...bugItems].map((item) => ({
  sheet: item.sheet,
  id: item.id,
  status: item.status,
  label: item.item ? `${item.browser} / ${item.page} / ${item.item}` : `${item.page ?? ""} / ${item.caseName ?? item.related ?? ""}`.replace(/^ \/ /, ""),
  memo: item.memo,
  evidence: item.evidence.map(rel),
}));

const evidenceIndexMd = [
  "# _reserve2 evidence index",
  "",
  "| sheet | id | status | evidence | memo |",
  "|---|---|---|---|---|",
  ...allItems.map((item) => `| ${item.sheet} | ${item.id} | ${item.status} | ${item.evidence.join("<br>")} | ${item.memo.replace(/\|/g, "\\|")} |`),
  "",
].join("\n");

const evidenceIndexCsvRows = [
  ["sheet", "id", "status", "label", "evidence_count", "evidence_files", "memo"],
  ...allItems.map((item) => [
    item.sheet,
    item.id,
    item.status,
    item.label,
    String(item.evidence.length),
    item.evidence.join(" ; "),
    item.memo,
  ]),
];

function toCsv(rows) {
  return rows
    .map((row) => row.map((cell = "") => `"${String(cell).replace(/"/g, "\"\"")}"`).join(","))
    .join("\n");
}

async function writeUtf8(filePath, text) {
  await fs.writeFile(filePath, `\uFEFF${text}`, "utf8");
}

await writeUtf8(path.join(reportDir, "test-summary.md"), testSummaryMd);
await writeUtf8(path.join(reportDir, "test-summary.csv"), toCsv(testSummaryCsvRows));
await writeUtf8(path.join(reportDir, "evidence-index.md"), evidenceIndexMd);
await writeUtf8(path.join(reportDir, "evidence-index.csv"), toCsv(evidenceIndexCsvRows));

const finalReport = {
  workbookPath,
  reportDir,
  counts: {
    A: {
      pass: aCounts["合格"] ?? 0,
      hold: aCounts["保留"] ?? 0,
      pending: aCounts["未実施"] ?? 0,
      excluded: aCounts["対象外"] ?? 0,
    },
    C: {
      pass: cCounts["合格"] ?? 0,
      hold: cCounts["保留"] ?? 0,
      fail: cCounts["不合格"] ?? 0,
      pending: cCounts["未実施"] ?? 0,
    },
    BUG: {
      resolved: bugCounts["対応済"] ?? 0,
      dataInsufficient: bugCounts["データ不足"] ?? 0,
      prodWait: bugCounts["本番確認待ち"] ?? 0,
    },
  },
};

console.log(JSON.stringify(finalReport, null, 2));
