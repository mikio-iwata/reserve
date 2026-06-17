# _reserve2 テスト実施サマリー（2026-06-12）

## 対象
- C:\sources\asp\netcampus\hao\work\_reserve2
- index.asp / main.asp / reserve.asp / error.asp
- etc/style.css

## 実施できた確認

### ソース検査
- index.asp / main.asp / reserve.asp / error.asp で `CodePage=932` を確認
- index.asp / main.asp / reserve.asp / error.asp で `Session.CodePage = 932` を確認
- index.asp / main.asp / reserve.asp / error.asp で `charset=shift_jis` を確認
- reserve.asp で `ReserveCls` の radio に id が付与されていることを確認
- reserve.asp でレッスン時刻・内容・状態が `schedule-choice-label` で radio と紐づくことを確認
- main.asp でキャンセル一覧SQLに `SELECT DISTINCT class_buffer ...` が入っていることを確認

### 静的ブラウザ表示確認（実ASP/DBなし）
対象プレビュー:
- test_evidence/index_single_base_preview.html
- test_evidence/main_single_base_preview.html
- test_evidence/reserve_single_base_preview.html

確認幅:
- 390px
- 768px
- 1366px

確認結果:
- index/main/reserve すべてで横スクロールなし
- 外側の白い土台が1つで表示されることを確認
- course-list / lesson-list / schedule-grid の薄背景と角丸を確認
- reserve の schedule-grid は枠線なし、モバイル時の各レッスン行も枠線なしを確認
- main の学校 select は枠線が残っていることを確認
- reserve の `schedule-choice-label` が6件、`ReserveCls` radio が2件あることを確認

## 証跡ファイル
- T_static_index_390.png
- T_static_index_1366.png
- T_static_main_390.png
- T_static_main_1366.png
- T_static_reserve_390.png
- T_static_reserve_1366.png

## 未実施
以下は実ASPサーバー、ログイン状態、実DBテストデータが必要なため、この環境では未実施。

- index.asp の実ログイン経由遷移
- main.asp の学校選択、予約画面遷移、キャンセル実行
- reserve.asp の実DBクラス一覧表示、予約実行、未選択エラー
- DB更新を伴う before/after 確認
- Win Chrome / Win Firefox / iOS Safari / Android Chrome / iPad Safari / macOS Safari 実機確認

## localhost 確認
以下URLは接続不可だったため、実ASPでの確認は未実施。

- http://localhost/_reserve2/index.asp
- http://localhost/work/_reserve2/index.asp
- http://localhost/hao/work/_reserve2/index.asp
- http://localhost/reserve/index.asp

## 注意
静的プレビュー確認は提出前の表示確認として有効だが、テスト仕様書の合格判定には実ASP/DB環境での再実施が必要。
