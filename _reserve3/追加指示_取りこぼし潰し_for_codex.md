# 追加指示：DBなしで今すぐ潰せる取りこぼし（Codex 用）

前回の結果は良好。ただし **error.asp と Firefox に「DB不要で実施できるのに未実施」の項目**が残っている。
ログイン/DBデータの準備を待たず、**今すぐこれだけ**を埋めること。v2手順の絶対ルール（証拠主義・エンジン偽装禁止・静的≠合格）は継続。

対象ファイル: `予約システム_レスポンシブ対応_テスト仕様書.xlsx`（A_表示・レスポンシブ シート）
証拠保存先: `_reserve/test_evidence/`

---

## やること（error.asp のみ。ログイン不要で到達可能）

### 1. 200%ズーム（A-11）— Win Chrome / Win Edge / Win Firefox の3つとも
- error.asp を開き、ブラウザズーム200%にしてスクショ取得。
- テキストが読め、重なり・見切れが無いことを確認。
- 証拠: `A_error_<ブラウザ>_zoom200.png`
- 判定を「合格／不合格」に更新（現在は未実施）。

### 2. Firefox の未計測項目を Chrome/Edge と同水準まで完了
Firefox の error.asp で以下を実施（Chrome/Edge は完了済み、Firefox だけ未実施）。
- **A-02 横スクロール**: 各幅で `document.documentElement.scrollWidth <= window.innerWidth` を計測。数値を `metrics_WinFirefox.json` に保存。
- **A-08 タップターゲット**: 操作要素を `getBoundingClientRect()` で実測し 44×44px 以上を確認。同 JSON に記録。
- **A-10 縦/横切替**: 375×667 と 667×375 のスクショ取得（エミュレーションなら memo に「実機未確認」明記）。
- **A-15 alt**: 画像無効化状態のスクショ取得し alt 表示を確認。
- 証拠ファイル名は既存規則に合わせる（例 `A_error_WinFirefox_375.png`, `metrics_WinFirefox.json`）。

### 3. A-12 文字コードの「ソース基準」確定（全画面・読み取りのみ）
画面表示確認はログインが要るため不可だが、**ASP先頭ディレクティブと meta charset の有無はソースで判定できる**。以下を事実として確認し、メモに記載：
- index.asp: `CodePage=932` / `Session.CodePage=932` あり
- main.asp: あり（修正済）
- reserve.asp: **無し**（BUG-002）
- error.asp: **無し**（BUG-004）
- ※ 画面の文字化け目視はログイン後に実施するため、index/main/reserve の A-12 判定は「未実施」のままとし、メモに「ソース基準のみ確認済（表示確認は要ログイン）」と付す。

---

## 記入ルール（再掲・厳守）

- 判定「合格／不合格」には **必ず証拠（スクショ名 or 計測値）をメモ欄に記載**。無ければ「未実施」のまま。
- Chromium で Firefox/他を代替しない。Firefox は Firefox で実測する。
- エミュレーション実施分は memo に「実機未確認」と明記。
- 列: A シート 8列=判定 / 9列=メモ(証拠) / 10列=実施者 / 11列=実施日。書式・プルダウンを壊さない。

---

## 完了条件

- error.asp の A-11（200%ズーム）が Chrome/Edge/Firefox で判定済み（証拠付き）。
- Firefox の error.asp が Chrome/Edge と同じ項目数まで埋まっている（未実施の取りこぼしが無い）。
- A-12 のソース基準が4画面ぶん事実記載されている。
- 追加スクショ/JSON が `test_evidence/` に保存されている。

> これは「データ待ちの3画面（index/main/reserve）」とは別作業。ここで index/main/reserve や Apple系を埋めようとしないこと（到達不可のため未実施/対象外のまま）。
