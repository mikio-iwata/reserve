# _reserve2 テスト続きサマリー（2026-06-15）

## 対象
- C:\sources\asp\netcampus\hao\work\_reserve2
- 予約システム_レスポンシブ対応_テスト仕様書.xlsx

## 今日実施した確認

### 1. localhost / IIS疎通確認
以下を確認したが、実ASP表示確認には到達できなかった。

- http://localhost/work/_reserve2/error.asp?Message=test : timeout
- http://localhost:8088/work/_reserve2/error.asp?Message=test : 404
- http://localhost/hao/work/_reserve2/error.asp?Message=test : timeout

結論: index/main/reserve の実ログイン・DB回帰テストは引き続き未実施。

### 2. Firefox数値測定の可否確認
- Firefox本体は存在する。
- geckodriver は見つからない。
- Python環境に selenium / playwright は無い。

結論: A-144 / A-147 は v2基準の数値証拠を取得できないため、未実施のまま維持。
既存のFirefoxスクリーンショットは視覚証跡に留める。

### 3. ソース基準確認
source_check_20260615.json に以下を保存。

- CodePage=932
- Session.CodePage = 932
- charset=shift_jis
- check_secure_programming.asp include有無
- ChkSecSql / ChkSecXss 使用有無

確認結果として、reserve.asp / error.asp の CodePage 対応済みを再確認。

## Excel更新
- 概要シートの対象・実施日・証拠保存先を _reserve2 に更新。
- A-144 / A-147 は「未実施」のまま、未実施理由を 2026/06/15 内容に更新。
- BUG-002 / BUG-004 の再テスト結果を 2026/06/15 ソース再確認済みに更新。

## 現在の判定数

### A_表示・レスポンシブ
- 合格: 28
- 不合格: 3
- 対象外: 188
- 未実施: 138

### C_機能回帰
- 合格: 7
- 不合格: 5
- 未実施: 21

## 残課題
- 実ASP/DB環境で index/main/reserve の機能回帰を実施する。
- Firefoxの数値測定は geckodriver/Selenium/Playwright 等の測定環境が必要。
- BUG-001 / BUG-003 は未対応のまま。
