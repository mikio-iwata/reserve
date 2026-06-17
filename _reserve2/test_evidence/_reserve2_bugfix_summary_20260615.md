# _reserve2 BUG-001 / BUG-003 修正サマリー（2026-06-15）

## BUG-001

### 問題
LogRecord が c:\log\hao\student_reservation.txt への書き込みに失敗すると、エラー遷移前に 800a0046 で処理が停止する可能性があった。

### 修正
work\_reserve2\etc\include.inc の LogRecord に On Error Resume Next を追加し、ログ書き込み失敗時も本処理を止めないようにした。

### 確認
- LogRecord 内に On Error Resume Next / Err.Clear / On Error GoTo 0 があることをソース確認。
- OpenTextFile 直後に無条件 WriteLine しない構造であることを確認。
- 実ASPルートは timeout/404 のため、機能再テストは未実施としてExcelに記録。

## BUG-003

### 問題
751～900px帯で .site-header img の矩形が .site-header コンテナを超えていた。

### 修正
work\_reserve2\etc\style.css に 751～900px 専用の media rule を追加し、画像をヘッダー幅内に収めた。

### 確認
ローカルHTTP経由で測定。

- 768px: headerWidth=744 / imgWidth=744 / imageExceedsHeader=false
- 900px: headerWidth=876 / imgWidth=876 / imageExceedsHeader=false

証跡: bugfix_metrics_20260615.json

## Excel反映
- BUG-001: 対応済。ただし実ASP疎通不可のため関連C行は未実施へ変更。
- BUG-003: 対応済。A-043 / A-094 / A-145 を合格へ変更。

## 現在の判定数

### A_表示・レスポンシブ
- 合格: 31
- 対象外: 188
- 未実施: 138
- 不合格: 0

### C_機能回帰
- 合格: 7
- 未実施: 26
- 不合格: 0
