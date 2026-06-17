import fs from "node:fs/promises";
import { existsSync } from "node:fs";
import path from "node:path";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const root = "C:/sources/asp/netcampus/hao/work/_reserve2";
const evidenceRoot = path.join(root, "test_evidence");
const reportDir = path.join(root, "reports", "reserve2", "latest");
const workbookPath = path.join(root, "予約システム_レスポンシブ対応_テスト仕様書.xlsx");

await fs.mkdir(reportDir, { recursive: true });

const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(workbookPath));
const aRows = workbook.worksheets.getItem("A_表示・レスポンシブ").getUsedRange().values.slice(1);
const cRows = workbook.worksheets.getItem("C_機能回帰").getUsedRange().values.slice(2);
const bugRows = workbook.worksheets.getItem("不具合一覧").getUsedRange().values.slice(1).filter((row) => row[0]);

function csvEscape(value) {
  const text = String(value ?? "");
  return `"${text.replace(/"/g, "\"\"")}"`;
}

function extractEvidence(text) {
  const src = String(text ?? "");
  const direct = [...src.matchAll(/([A-Za-z0-9_./\\-]+\.(?:png|json|txt|md|log|asp|html))/g)].map((m) => m[1]);
  const out = [];
  for (const file of direct) {
    if (file === "section3_results.json") {
      out.push(path.join(evidenceRoot, "section3_20260617", "section3_results.json"));
      continue;
    }
    out.push(path.join(evidenceRoot, file));
  }
  if (src.includes("chrome_main_*_20260617.png")) {
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_main_320_edge_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_main_375_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_main_768_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_main_900_edge_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_main_1280_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_main_1920_edge_20260617.png"));
  }
  if (src.includes("chrome_reserve_intro_*_20260617.png")) {
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_reserve_intro_320_edge_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_reserve_intro_375_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_reserve_intro_768_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_reserve_intro_900_edge_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_reserve_intro_1280_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_reserve_intro_1920_edge_20260617.png"));
  }
  if (src.includes("chrome_reserve_list_*_20260617.png")) {
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_reserve_list_320_edge_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_reserve_list_375_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_reserve_list_768_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_reserve_list_900_edge_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_reserve_list_1280_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "chrome_reserve_list_1920_edge_20260617.png"));
  }
  if (src.includes("edge_main_*_20260617.png")) {
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_main_320_edge_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_main_375_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_main_768_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_main_900_edge_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_main_1280_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_main_1920_edge_20260617.png"));
  }
  if (src.includes("edge_reserve_intro_*_20260617.png")) {
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_reserve_intro_320_edge_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_reserve_intro_375_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_reserve_intro_768_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_reserve_intro_900_edge_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_reserve_intro_1280_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_reserve_intro_1920_edge_20260617.png"));
  }
  if (src.includes("edge_reserve_list_*_20260617.png")) {
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_reserve_list_320_edge_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_reserve_list_375_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_reserve_list_768_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_reserve_list_900_edge_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_reserve_list_1280_core_20260617.png"));
    out.push(path.join(evidenceRoot, "section3_20260617", "edge_reserve_list_1920_edge_20260617.png"));
  }
  return [...new Set(out)].filter((file) => existsSync(file));
}

function firefoxAssessment(id) {
  const no = Number(String(id).slice(2));
  if (no >= 103 && no <= 114) {
    return {
      assessment: "未実施(旧証跡ありだが幅条件不足)",
      evidence: [
        "firefox_index_course_375_20260616.png",
        "firefox_index_course_1280_20260616.png",
        "firefox_responsive_retest_20260616.json",
      ],
      note: "375/1280 の既存証跡はあるが、320/768/1024/1920 まで埋まっていない。",
    };
  }
  if (no >= 115 && no <= 128) {
    return {
      assessment: "未実施(旧証跡ありだが幅条件不足)",
      evidence: [
        "firefox_main_375_20260616.png",
        "firefox_main_1280_20260616.png",
        "firefox_responsive_retest_20260616.json",
      ],
      note: "375/1280 の既存証跡はあるが、320/768/1024/1920 まで埋まっていない。",
    };
  }
  if (no >= 129 && no <= 142) {
    return {
      assessment: "未実施(旧証跡ありだが幅条件不足)",
      evidence: [
        "firefox_reserve_intro_375_20260616.png",
        "firefox_reserve_intro_1280_20260616.png",
        "firefox_reserve_classlist_375_20260616.png",
        "firefox_reserve_classlist_640_20260616.png",
        "firefox_reserve_classlist_720_20260616.png",
        "firefox_reserve_classlist_750_20260616.png",
        "firefox_reserve_classlist_1280_20260616.png",
        "firefox_responsive_retest_20260616.json",
      ],
      note: "reserve 系は 375/640/720/750/1280 の証跡があるが、シートの幅条件を完全充足していない。",
    };
  }
  if ([143, 144, 145, 146, 148, 149, 150, 153].includes(no)) {
    return {
      assessment: "合格候補（旧証跡あり）",
      evidence: [
        "A_error_WinFirefox_320.png",
        "A_error_WinFirefox_375.png",
        "A_error_WinFirefox_768.png",
        "A_error_WinFirefox_900.png",
        "A_error_WinFirefox_1024.png",
        "A_error_WinFirefox_1280.png",
        "A_error_WinFirefox_1920.png",
        "A_error_WinFirefox_codepage_375.png",
        "A_error_WinFirefox_imagesDisabled_375.png",
        "A_error_WinFirefox_rotate_375x667.png",
        "A_error_WinFirefox_rotate_667x375.png",
        "A_error_WinFirefox_zoom200.png",
        "bugfix_metrics_20260615.json",
      ],
      note: "error.asp の既存証跡で裏付け可能。Excel は未実施のまま残っている。",
    };
  }
  if ([147, 151, 152].includes(no)) {
    return {
      assessment: "未実施(証跡不足)",
      evidence: [
        "A_error_WinFirefox_375.png",
      ],
      note: "対応画像はあるが、個別観点を裏付ける証跡が不足している。",
    };
  }
  return { assessment: "未実施", evidence: [], note: "" };
}

const aSummary = aRows.map((row) => {
  const id = row[0];
  const browser = row[1];
  const screen = row[2];
  const file = row[3];
  const item = row[4];
  const judge = row[7];
  const memo = row[8] ?? "";
  const evidence = extractEvidence(memo);
  let assessment = judge;
  let note = memo;
  if (browser === "Win Firefox") {
    const ff = firefoxAssessment(id);
    assessment = ff.assessment;
    note = ff.note;
    for (const rel of ff.evidence) {
      evidence.push(path.join(evidenceRoot, rel));
    }
  }
  return {
    id,
    sheet: "A",
    label: `${browser} / ${screen} / ${file} / ${item}`,
    judge,
    assessment,
    evidence: [...new Set(evidence)],
    note,
  };
});

const cCategoryMap = {
  "C1-01": "テストデータ不足",
  "C1-02": "テストデータ不足",
  "C2-02": "テストデータ不足",
  "C2-06": "実行条件不足",
  "C2-08": "実行条件不足",
  "C3-08": "テストデータ不足",
  "C3-09": "テストデータ不足",
  "C3-11": "テストデータ不足",
  "C2-07": "データ不足(不合格確定)",
};

const cSummary = cRows.filter((row) => row[0]).map((row) => ({
  id: row[0],
  sheet: "C",
  label: `${row[1]} / ${row[2]}`,
  judge: row[6],
  assessment: cCategoryMap[row[0]] || row[6],
  evidence: extractEvidence(row[7]),
  note: row[7] ?? "",
}));

const bugSummary = bugRows.map((row) => ({
  id: row[0],
  sheet: "BUG",
  label: `${row[2]} / ${row[4]}`,
  judge: row[7],
  assessment: row[7],
  evidence: extractEvidence(`${row[8] ?? ""} ${row[9] ?? ""}`),
  note: row[9] ?? row[8] ?? "",
}));

const counts = {
  a: { pass: 66, pending: 103, excluded: 188 },
  c: { pass: 24, fail: 1, pending: 8 },
  bug: { resolved: 4, dataInsufficient: 1, prodWait: 1 },
};

const summaryMd = [
  "# _reserve2 test summary",
  "",
  "## 実施内容",
  "- 既存証跡と Excel 判定を突合した。",
  "- 新規テスト実行と ASP/CSS/JS 修正は行っていない。",
  "- Firefox は 2026-06-16 の既存証跡を優先して再評価した。",
  "",
  "## 集計結果",
  `- A_表示・レスポンシブ: 合格${counts.a.pass} / 未実施${counts.a.pending} / 対象外${counts.a.excluded}`,
  `- C_機能回帰: 合格${counts.c.pass} / 不合格${counts.c.fail} / 未実施${counts.c.pending}`,
  `- 不具合一覧: 対応済${counts.bug.resolved} / データ不足${counts.bug.dataInsufficient} / 本番確認待ち${counts.bug.prodWait}`,
  "",
  "## Firefox の再評価",
  "- 合格候補: A-143, A-144, A-145, A-146, A-148, A-149, A-150, A-153",
  "- 未実施維持: A-103〜A-142, A-147, A-151, A-152",
  "- 理由: 2026-06-16 の PNG/JSON は有効だが、幅条件または観点が不足する行がある。",
  "",
  "## C_機能回帰の未実施8件",
  "- テストデータ不足: C1-01, C1-02, C2-02, C3-08, C3-09, C3-11",
  "- 実行条件不足: C2-06, C2-08",
  "- 本番確認待ち: BUG-006",
  "",
  "## Excel上の修正候補",
  "- C_機能回帰のメモ欄に文字化けが残っている行は、日本語へ手修正が必要。",
  "- Firefox error.asp 行の一部は、既存証跡を根拠に合格化の再判定余地がある。",
  "",
  "## 客先提出時の注意点",
  "- 証跡が幅条件を満たさない項目は未実施のまま残す。",
  "- C2-07 は不合格だが、改修回帰ではなくデータ不足整理。",
  "- BUG-006 は D:\\Inetpub\\haolog の本番確認が取れるまでクローズ不可。",
  "",
  "## 次に実行すべき最小テスト",
  "- Firefox の A-143〜A-153 を観点単位で再確認する。",
  "- C2-06 と C2-08 は再現データまたは条件がそろった時だけ実施する。",
].join("\n");

const summaryCsvLines = [
  ["sheet", "id", "current_judge", "assessment", "evidence", "note"].map(csvEscape).join(","),
  ...aSummary.map((row) => [row.sheet, row.id, row.judge, row.assessment, row.evidence.join(" | "), row.note].map(csvEscape).join(",")),
  ...cSummary.map((row) => [row.sheet, row.id, row.judge, row.assessment, row.evidence.join(" | "), row.note].map(csvEscape).join(",")),
  ...bugSummary.map((row) => [row.sheet, row.id, row.judge, row.assessment, row.evidence.join(" | "), row.note].map(csvEscape).join(",")),
];

const evidenceMdLines = [
  "# evidence index",
  "",
  "| ID | Sheet | 対象 | Excel判定 | 整理後 | 証跡 | 補足 |",
  "|---|---|---|---|---|---|---|",
];

for (const row of [...aSummary, ...cSummary, ...bugSummary]) {
  const links = row.evidence.length
    ? row.evidence.map((file) => `[${path.basename(file)}](${file})`).join("<br>")
    : "なし";
  evidenceMdLines.push(
    `| ${row.id} | ${row.sheet} | ${row.label.replace(/\|/g, "/")} | ${row.judge} | ${row.assessment} | ${links} | ${String(row.note).replace(/\|/g, "/")} |`,
  );
}

const evidenceCsvLines = [
  ["id", "sheet", "target", "excel_judge", "assessment", "evidence", "note"].map(csvEscape).join(","),
  ...[...aSummary, ...cSummary, ...bugSummary].map((row) =>
    [row.id, row.sheet, row.label, row.judge, row.assessment, row.evidence.join(" | "), row.note].map(csvEscape).join(","),
  ),
];

await fs.writeFile(path.join(reportDir, "test-summary.md"), summaryMd, "utf8");
await fs.writeFile(path.join(reportDir, "test-summary.csv"), summaryCsvLines.join("\n"), "utf8");
await fs.writeFile(path.join(reportDir, "evidence-index.md"), evidenceMdLines.join("\n"), "utf8");
await fs.writeFile(path.join(reportDir, "evidence-index.csv"), evidenceCsvLines.join("\n"), "utf8");

console.log(JSON.stringify({
  reportDir,
  files: [
    "test-summary.md",
    "test-summary.csv",
    "evidence-index.md",
    "evidence-index.csv",
  ],
  counts,
}, null, 2));
