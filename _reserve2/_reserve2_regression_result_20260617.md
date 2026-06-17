# _reserve2_regression_result_20260617

## 結論
- `2026-06-16` までに取得済みだった実機証跡を根拠に、Excel の `?? / ???` 判定を正式な `合格 / 不合格` へ補正した。
- `C_機能回帰` の正式件数は **合格24 / 不合格1 / 未実施8** で確定。
- `A_表示・レスポンシブ` は Excel 上で **合格66 / 未実施103 / 対象外188**。
- したがって、次に着手すべきは **未実施8件の実行可否整理** と **BUG-006 の本番確認要否整理**。
## 今回反映した内容
- `C:\sources\asp\netcampus\hao\work\_reserve2\予約システム_レスポンシブ対応_テスト仕様書.xlsx`
  - `A_表示・レスポンシブ` シート:
    - 既存証跡があった `Win Edge / Win Firefox` の `??` 行を `合格` に補正
  - `C_機能回帰` シート:
    - 既存証跡があった `??` 行を `合格` に補正
    - `C2-07` の `???` を `不合格` に補正
  - `不具合一覧` シート:
    - `BUG-005` を追加し、状態を `データ不足` で記録
    - `BUG-006` を追加し、状態を `本番確認待ち` で記録

## C_機能回帰の現状
- 合格: 24
- 不合格: 1
- 未実施: 8

### 不合格
- `C2-07`
  - 内容: `CourseType=2` のキャンセル一覧で `text_name / lesson_name` が空になる
  - BUG: `BUG-005`
  - 整理: 改修起因ではなく、対象データ不足により `LEFT JOIN` 結果が `NULL / 空文字` になっている

### 未実施
- `C1-01` 該当コース0件
- `C1-02` 該当コース1件
- `C2-02` 残回数0
- `C2-06` 予約済リスト (`CourseType=1`)
- `C2-08` キャンセル期限内のレッスン
- `C3-08` 満員 (`total=0`)
- `C3-09` 予約期限切れ
- `C3-11` 時間重複クラス

### 今回追加で合格化した項目
- `C1-06`
  - `index.asp` を script-opened popup で開き、`閉じる` 押下後に `window.close()` で popup が閉じることを Chrome 実機で確認
  - evidence:
    - `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\C1_06_popup_before_close_chrome_20260617.png`
    - `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\chrome_c1_c2_probe_20260617.json`

## A_表示・レスポンシブの現状
- 合格: 66
- 未実施: 103
- 対象外: 188

### 2026-06-17 セクション3反映
- Chrome
  - main.asp / reserve.asp の section3 実測を反映し、直接証跡がある項目を合格へ更新
  - 画面回転 / 200%ズーム / 画像欠落時(alt) / 長文端値 は今回の証跡対象外のため既存の未実施を維持
- Edge
  - section3 の Chrome 判定基準を Edge 画像へ転記し、対応項目を更新
- Firefox
  - launchPersistentContext 起動ブロッカーのため A-103〜A-153 を未実施で統一

### 根拠にした主な証跡
- `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\section3_20260617\section3_results.json`
- `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\section3_20260617\chrome_main_*_20260617.png`
- `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\section3_20260617\chrome_reserve_intro_*_20260617.png`
- `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\section3_20260617\chrome_reserve_list_*_20260617.png`
- `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\section3_20260617\edge_main_*_20260617.png`
- `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\section3_20260617\edge_reserve_intro_*_20260617.png`
- `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\section3_20260617\edge_reserve_list_*_20260617.png`

## BUGの現状
- `BUG-001`: 対応済
- `BUG-002`: 対応済
- `BUG-003`: 対応済
- `BUG-004`: 対応済
- `BUG-005`: データ不足
- `BUG-006`: 本番確認待ち

## 次の着手順
1. `C1-06` を popup 条件つきで実行可能か再確認
2. 未実施8件を、実行可能なら実施、不可なら `データ不足` として明記
3. `BUG-006` を本番相当環境確認待ちとして残すか、確認環境があるなら消化

## 2026-06-17 時点の残件切り分け
- `C1-01 / C1-02`
  - current account `uid=3070` では予約可能コースが 2 件 (`61`, `77`)
  - このアカウントでは再現不能
- `C2-02`
  - current account の残回数は 17
  - `残回数0` は再現不能
- `C2-06`
  - `CourseType=1` は `course 77`（オンラインチャイナ）
  - current account `uid=3070` には `course 77` の予約済データが存在しない
  - `course 61` は `CourseType=2` のため C2-06 対象外
- `C2-08`
  - current account の予約済レッスンはキャンセル期限超過ではない
  - 再現不能
- `C3-08 / C3-09 / C3-11`
  - current account / current future data では
    - `満席(total=0)`
    - `締切後`
    - `時間重複`
    のいずれも該当なし

### 追加証跡
- `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\remaining_case_probe_20260617.txt`
- `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\uid_course_probe.asp`
- `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\scenario_probe.asp`
