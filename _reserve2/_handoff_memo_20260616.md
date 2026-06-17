# _reserve2 引き継ぎメモ 2026-06-16

## 結論
`_reserve2` の表示境界幅再試験は、Chrome と Edge は完了。Firefox は未完了。

Firefox は Playwright 管理下のウィンドウで人間ログイン後に自動実行する方式へ切り替え中だが、まだ最後まで証跡取得できていない。次の担当者は Firefox の続きから再開する。

## 対象
- 作業ディレクトリ: `C:\sources\asp\netcampus\hao\work\_reserve2`
- 対象画面:
  - `index.asp`
  - `main.asp`
  - `reserve.asp`
- 証跡保存先:
  - `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence`

## 直近の背景
以前の表示テストで `reserve.asp` の中間幅、特に `750px` 前後の表示崩れを見落とした。

原因は、`375px / 1280px` の代表幅中心で確認しており、CSS切替点をまたぐ `900 / 820 / 760 / 750 / 720 / 640 / 375` のような境界幅確認が不足していたこと。

このため、既存の表示合格結果はいったん参考扱いに落とし、実機ブラウザで境界幅再試験をやり直している。

## 修正済み内容
`work/_reserve2/etc/style.css` を修正済み。

内容:
- `reserve.asp` の予約可能クラス一覧のカード表示切替を `750px以下` から `640px以下` に変更
- `720px / 750px` では表形式を維持
- `640px / 375px` ではカード形式に切替

in-app browser では以下を確認済み:
- `reserve_classlist`
  - `720px`: `thead` 表示、`tr = table-row`
  - `640px`: `thead` 非表示、`tr = grid`
  - `375px`: `thead` 非表示、`tr = grid`
- 横スクロールなし

## インシデントレポート
作成済み:
- `C:\sources\asp\netcampus\hao\work\_reserve2\_reserve2_incident_report_20260615.md`

要点:
- 旧表示テスト結果は納品判定にそのまま使えない
- `index.asp / main.asp / reserve.asp` の表示確認は境界幅込みで再試験が必要
- 現時点の納品判定は「納品不可」

## in-app browser 再試験
作成済み:
- `C:\sources\asp\netcampus\hao\work\_reserve2\_reserve2_display_retest_20260615.md`

証跡:
- `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\iab_responsive_retest_20260615.json`
- `C:\sources\asp\netcampus\hao\work\_reserve2\test_evidence\*_IAB_20260615.png`

これは暫定確認。正式な納品証跡は Chrome / Edge / Firefox 実機確認で置き換える方針。

## Chrome 実機再試験
完了済み。

実施日:
- 2026-06-16

対象:
- `index_course`
- `main`
- `reserve_intro`
- `reserve_classlist`

確認幅:
- `index_course`: `375 / 1280`
- `main`: `375 / 1280`
- `reserve_intro`: `375 / 1280`
- `reserve_classlist`: `375 / 640 / 720 / 750 / 1280`

証跡:
- `test_evidence\chrome_index_course_375_20260616.png`
- `test_evidence\chrome_index_course_1280_20260616.png`
- `test_evidence\chrome_main_375_20260616.png`
- `test_evidence\chrome_main_1280_20260616.png`
- `test_evidence\chrome_reserve_intro_375_20260616.png`
- `test_evidence\chrome_reserve_intro_1280_20260616.png`
- `test_evidence\chrome_reserve_classlist_375_20260616.png`
- `test_evidence\chrome_reserve_classlist_640_20260616.png`
- `test_evidence\chrome_reserve_classlist_720_20260616.png`
- `test_evidence\chrome_reserve_classlist_750_20260616.png`
- `test_evidence\chrome_reserve_classlist_1280_20260616.png`
- `test_evidence\chrome_responsive_retest_20260616.json`

結果:
- JSON上、横スクロールなし
- `reserve_classlist` は `640px` でカード表示、`720px / 750px` で表表示

## Edge 実機再試験
完了済み。

実施日:
- 2026-06-16

対象と幅は Chrome と同じ。

証跡:
- `test_evidence\edge_index_course_375_20260616.png`
- `test_evidence\edge_index_course_1280_20260616.png`
- `test_evidence\edge_main_375_20260616.png`
- `test_evidence\edge_main_1280_20260616.png`
- `test_evidence\edge_reserve_intro_375_20260616.png`
- `test_evidence\edge_reserve_intro_1280_20260616.png`
- `test_evidence\edge_reserve_classlist_375_20260616.png`
- `test_evidence\edge_reserve_classlist_640_20260616.png`
- `test_evidence\edge_reserve_classlist_720_20260616.png`
- `test_evidence\edge_reserve_classlist_750_20260616.png`
- `test_evidence\edge_reserve_classlist_1280_20260616.png`
- `test_evidence\edge_responsive_retest_20260616.json`

結果:
- JSON上、横スクロールなし
- `reserve_classlist` は `640px` でカード表示、`720px / 750px` で表表示

## Firefox 実機再試験
未完了。

### ここまでの状況
Firefox は何度か詰まった。

主な原因:
- Playwright の Firefox ランタイムが古いパスを見ていた
- `parent.lock` が残ってプロファイルを掴めなかった
- 手動起動した Firefox と Playwright 管理下 Firefox のプロファイルを取り合った
- 人間ログイン後にブラウザを閉じると ASP セッションが消えた
- 自動化スクリプトがコース radio を曖昧に選んで止まった
- 学校選択で `5221` を明示していなかったため、`reserve_intro` 以降で止まった疑い

### 済んでいる対応
- `npx playwright install firefox` 実行済み
- `C:\Users\IwataMikio\AppData\Local\ms-playwright\firefox-1522\firefox\firefox.exe` が存在
- `C:\codex_ff_profile\parent.lock` を削除して再起動する流れは確認済み
- Playwright管理下で Firefox を起動し、人間ログインを待つ方式に変更済み

### 一部出た Firefox 証跡
途中まで出力されたもの:
- `test_evidence\firefox_index_course_375_20260616.png`
- `test_evidence\firefox_index_course_1280_20260616.png`
- `test_evidence\firefox_main_375_20260616.png`
- `test_evidence\firefox_main_1280_20260616.png`

ただし、Firefox 再試験全体としては未完了扱い。

### 最後に起動したスクリプト
ファイル:
- `C:\codex_pw\firefox_retest_wait_and_run.js`

最後の修正版の意図:
- Firefox を Playwright 管理下で起動
- `login2.asp` を表示
- 人間がログインして `_reserve2/index.asp` を表示するまで待機
- `input[name="SelectCourse"][value^="61,"]` を使って「オンラインレッスン＆WEBセミナー」を一意に選択
- `select[name="School"]` で `5221` を明示選択
- 以下の証跡を保存する
  - `firefox_index_course_375_20260616.png`
  - `firefox_index_course_1280_20260616.png`
  - `firefox_main_375_20260616.png`
  - `firefox_main_1280_20260616.png`
  - `firefox_reserve_intro_375_20260616.png`
  - `firefox_reserve_intro_1280_20260616.png`
  - `firefox_reserve_classlist_375_20260616.png`
  - `firefox_reserve_classlist_640_20260616.png`
  - `firefox_reserve_classlist_720_20260616.png`
  - `firefox_reserve_classlist_750_20260616.png`
  - `firefox_reserve_classlist_1280_20260616.png`
  - `firefox_responsive_retest_20260616.json`

### 次の担当者がやること
1. 残留 Firefox / node を止める
2. `C:\codex_ff_profile\parent.lock` があれば削除
3. `C:\codex_pw\firefox_retest_wait_and_run.js` を起動
4. 起動した Firefox で人間がログイン
5. `_reserve2/index.asp` が表示された状態で待機
6. 自動で証跡取得が進むか確認
7. `test_evidence\firefox_responsive_retest_20260616.json` と PNG 一式が揃えば完了

参考コマンド:

```powershell
Get-Process firefox,node -ErrorAction SilentlyContinue |
  Where-Object { $_.Path -like '*firefox*' -or $_.Path -like '*Volta*' } |
  Stop-Process -Force

if (Test-Path 'C:\codex_ff_profile\parent.lock') {
  Remove-Item -LiteralPath 'C:\codex_ff_profile\parent.lock' -Force
}

Start-Process -FilePath 'node' `
  -ArgumentList @('C:\codex_pw\firefox_retest_wait_and_run.js') `
  -WorkingDirectory 'C:\codex_pw' `
  -WindowStyle Normal
```

## 機能回帰の残件
表示再試験とは別に、機能回帰はまだ未完了。

既存記録:
- `C_機能回帰`: 合格23 / 不合格1 / 未実施9

不合格:
- `C2-07 = BUG-005`
  - 原因はコード回帰ではなくデータ不足で切り分け済み
  - `text_name / lesson_name` が空の対象データにより空表示

本番確認待ち:
- `BUG-006`
  - `D:\Inetpub\haolog\lesson_reserve_cancel.log` のログ出力
  - 現テスト機では環境起因の疑い

未実施:
- `C1-01`
- `C1-02`
- `C1-06`
- `C2-02`
- `C2-06`
- `C2-08`
- `C3-08`
- `C3-09`
- `C3-11`

## 現時点の納品判定
納品不可。

理由:
- Firefox 実機表示再試験が未完了
- 機能回帰の未実施9件が残っている
- `BUG-006` が本番確認待ち

## 次の完了条件
1. Firefox 実機表示再試験を完了
2. `firefox_*_20260616.png` と `firefox_responsive_retest_20260616.json` を保存
3. `Chrome / Edge / Firefox` の表示再試験結果を回帰結果MDに反映
4. Excel の A表示行を更新
5. 機能回帰未実施9件を、実行またはデータ不足として明確に整理
6. 納品可否を再判定
