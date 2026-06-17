# _reserve2_regression_result_20260615

## 結論
- ログイン済み Chrome タブ（CDP: `http://127.0.0.1:9222`, page id `CE93DBB5C7288767327FC97C871B384D`）を再利用して `_reserve2` の回帰テストを追加実施した。
- ログイン済み Edge タブ（CDP: `http://127.0.0.1:9223`, page id `C887BB7E6CD4505D712B8478B2736BA8`）でも `_reserve2` の A_表示・レスポンシブを追加確認した。
- 正規フロー `index.asp -> コース選択 -> main.asp -> school選択 -> reserve.asp` で Chrome 実機確認を行い、セッション切断は発生しなかった。
- 正規フロー `index.asp -> コース選択 -> main.asp -> school選択 -> reserve.asp` で Edge 実機確認を行い、セッション切断は発生しなかった。
- Playwright 起動 Firefox でも人手ログイン後の正規フロー `index.asp -> コース選択 -> main.asp -> school選択 -> reserve.asp` を実行し、375px / 1280px の証跡を取得した。
- Win Chrome の表示確認は `index / main / reserve` の 375px / 1280px で overflow なし、ヘッダーはみ出しなしを確認した。
- Win Edge の表示確認は `index / main / reserve` の 375px / 1280px で overflow なし、ヘッダーはみ出しなしを確認した。
- Win Firefox の表示確認は `index / main / reserve` の 375px / 1280px で overflow なし、ヘッダーはみ出しなしを確認した。

## 今回の追加確認（Win Chrome 実機, ログイン済み既存タブ）
- `index.asp`
  - 375px: `scrollWidth=375`, `innerWidth=375`, header overflowなし
  - 1280px: `scrollWidth=1280`, `innerWidth=1280`, header overflowなし
- `main.asp`
  - 375px: `scrollWidth=360`, `innerWidth=375`, header overflowなし
  - 1280px: `scrollWidth=1280`, `innerWidth=1280`, header overflowなし
- `reserve.asp`
  - intro(375px): `scrollWidth=375`, `innerWidth=375`, header overflowなし
  - class list(375px): `scrollWidth=360`, `innerWidth=375`, header overflowなし
  - intro(1280px): `scrollWidth=1280`, `innerWidth=1280`, header overflowなし
  - class list(1280px): `scrollWidth=1265`, `innerWidth=1280`, header overflowなし

## BUGの現状
- `BUG-005` (C2-07): **データ不足で確定**
  - 元版 `reserve/main.asp` でも同じ LEFT JOIN 構造
  - 対象クラス `6629ni`, `6629z6` は `textid=''`, `text_name=''`, `lesson_name=''`
  - 改修起因ではなく、データ不足による NULL/空文字表示
- `BUG-006`: **本番確認待ち / 環境起因の疑い**
  - `D:` ドライブは存在
  - ただし `D:\Inetpub\haolog` は現テスト機に存在せず、`lesson_reserve_cancel.log` は出力されない
  - `C:\log\hao\student_reservation.txt` には `エラー71 ディスクは準備されていません。` が残る

## C_機能回帰の現状
- 既存確定結果: 合格23 / 不合格1 / 未実施9
- 今回のChromeログイン済みタブ再利用では、Cの新規消化はなし
  - 理由: 既に実施済みの正規フローと同等の確認は取れたが、残る未実施は専用データまたは別実機条件が必要

## A_表示・レスポンシブの現状
- Win Chrome（ログイン済み実機タブ）
  - `index / main / reserve` の 375px / 1280px は証跡取得済み
- Win Edge（ログイン済み実機タブ）
  - `index.asp`
    - 375px: `scrollWidth=375`, `innerWidth=375`, header overflowなし
    - 1280px: `scrollWidth=1280`, `innerWidth=1280`, header overflowなし
  - `main.asp`
    - 375px: `scrollWidth=360`, `innerWidth=375`, header overflowなし
    - 1280px: `scrollWidth=1280`, `innerWidth=1280`, header overflowなし
  - `reserve.asp`
    - 375px: `scrollWidth=375`, `innerWidth=375`, header overflowなし
    - 1280px: `scrollWidth=1280`, `innerWidth=1280`, header overflowなし
- Win Firefox
  - `index.asp`
    - 375px: `scrollWidth=375`, `innerWidth=375`, header overflowなし
    - 1280px: `scrollWidth=1280`, `innerWidth=1280`, header overflowなし
  - `main.asp`
    - 375px: `scrollWidth=375`, `innerWidth=375`, header overflowなし
    - 1280px: `scrollWidth=1280`, `innerWidth=1280`, header overflowなし
  - `reserve.asp`
    - 375px: `scrollWidth=375`, `innerWidth=375`, header overflowなし
    - 1280px: `scrollWidth=1280`, `innerWidth=1280`, header overflowなし

## C1-06 「閉じる」
- Codex in-app browser では `window.close()` が閉じず判定保留
- 今回の Chrome ログイン済みタブでは、本番運用に近い popup 起動条件を再現できていないため、合格/不具合の断定はしない
- ツール/起動方式制約として未実施扱いを維持する

## 納品可否の所見
- **現時点では納品可とは判定しない。**
- 理由は、
  1. C_機能回帰に未実施9件が残っている
  2. `BUG-006` が本番確認待ち
- 一方で `BUG-005` は改修起因ではなくデータ不足と切り分け済みで、修正ブロッカーではない

## 残ブロッカー一覧
- 未実施9件用の専用データ未投入
  - C1-01, C1-02, C2-02, C2-06, C2-08, C3-08, C3-09, C3-11
- `BUG-006` の本番相当環境確認未完了

## 証跡
- Chromeスクリーンショット
  - `work/_reserve2/test_evidence/A_index_WinChrome_375_20260615.png`
  - `work/_reserve2/test_evidence/A_index_WinChrome_1280_20260615.png`
  - `work/_reserve2/test_evidence/A_main_WinChrome_375_20260615.png`
  - `work/_reserve2/test_evidence/A_main_WinChrome_1280_20260615.png`
  - `work/_reserve2/test_evidence/A_reserve_WinChrome_375_20260615.png`
  - `work/_reserve2/test_evidence/A_reserve_WinChrome_1280_20260615.png`
- Edgeスクリーンショット
  - `work/_reserve2/test_evidence/A_index_WinEdge_375_20260615.png`
  - `work/_reserve2/test_evidence/A_index_WinEdge_1280_20260615.png`
  - `work/_reserve2/test_evidence/A_main_WinEdge_375_20260615.png`
  - `work/_reserve2/test_evidence/A_main_WinEdge_1280_20260615.png`
  - `work/_reserve2/test_evidence/A_reserve_WinEdge_375_20260615.png`
  - `work/_reserve2/test_evidence/A_reserve_WinEdge_1280_20260615.png`
- Firefoxスクリーンショット
  - `work/_reserve2/test_evidence/A_index_WinFirefox_375_20260615.png`
  - `work/_reserve2/test_evidence/A_index_WinFirefox_1280_20260615.png`
  - `work/_reserve2/test_evidence/A_main_WinFirefox_375_20260615.png`
  - `work/_reserve2/test_evidence/A_main_WinFirefox_1280_20260615.png`
  - `work/_reserve2/test_evidence/A_reserve_WinFirefox_375_20260615.png`
  - `work/_reserve2/test_evidence/A_reserve_WinFirefox_1280_20260615.png`
- 数値証跡
  - `work/_reserve2/test_evidence/chrome_loggedin_metrics_20260615.json`
  - `work/_reserve2/test_evidence/edge_loggedin_metrics_20260615.json`
  - `work/_reserve2/test_evidence/firefox_loggedin_metrics_20260615.json`
- 既存の機能回帰証跡
  - `work/_reserve2/test_evidence/runtime_regression_notes_20260615.txt`
