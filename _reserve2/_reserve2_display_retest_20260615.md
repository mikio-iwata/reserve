# _reserve2 表示再試験結果 2026-06-15

## 結論
- `index.asp / main.asp / reserve.asp` を in-app browser で再試験した。
- 今回の修正により、`reserve.asp` の予約可能クラス一覧は `720px` までは表形式、`640px` 以下でカード形式に切り替わり、前回のような `750px` 近辺の中途半端な崩れは解消した。
- 一方で、この再試験は **in-app browser 単独** の結果であり、客先納品判定に使う正式結果にするには Chrome / Edge / Firefox 実機で同じ境界幅の再試験が必要。

## 試験対象
- `C:\sources\asp\netcampus\hao\work\_reserve2\index.asp`
- `C:\sources\asp\netcampus\hao\work\_reserve2\main.asp`
- `C:\sources\asp\netcampus\hao\work\_reserve2\reserve.asp`

## 試験条件
- 画面遷移:
  - `index.asp`（コース選択）
  - `main.asp`（予約・キャンセル）
  - `reserve.asp?School=5221`（日付未選択）
  - `reserve.asp?ClassYear=2026&ClassMonth=6&ClassDate=29&School=5221`（日付選択後）
- 確認幅:
  - `1280 / 900 / 820 / 760 / 750 / 720 / 640 / 375`
- 確認項目:
  - 横スクロール有無
  - `reserve.asp` 一覧の切替状態
  - カレンダー・ボタン・土台の崩れ有無

## 結果要約

### 1. index.asp
- 全幅で `scrollWidth <= innerWidth`
- 横スクロールなし
- コース選択UIは維持

### 2. main.asp
- 全幅で `scrollWidth <= innerWidth`
- 横スクロールなし
- 予約・キャンセル画面は維持

### 3. reserve.asp（日付未選択）
- 全幅で `scrollWidth <= innerWidth`
- 横スクロールなし
- カレンダーは `375px` まで表示維持

### 4. reserve.asp（日付選択後）
- 全幅で `scrollWidth <= innerWidth`
- `900 / 820 / 760 / 750 / 720`:
  - 一覧は表形式のまま維持
  - `thead` 表示あり
  - `tr display = table-row`
- `640 / 375`:
  - 一覧はカード形式へ切替
  - `thead` 非表示
  - `tr display = grid`
- 前回問題になった `750px` 近辺での早すぎる切替は解消

## 数値確認メモ
- `reserve_classlist`
  - `720px`: `tableHeadVisible = true`, `firstRowDisplay = table-row`
  - `640px`: `tableHeadVisible = false`, `firstRowDisplay = grid`
  - `375px`: `tableHeadVisible = false`, `firstRowDisplay = grid`

## 目視確認メモ
- `640px`:
  - カレンダー、注意書き、予約一覧、ボタンの並びは成立
- `375px`:
  - 予約一覧はカードとして成立
  - パンくずは2行以上に折り返すが、重なりはなし
  - 画面下部まで含めて、前回のような一覧崩壊は確認されず

## 注意事項
- ヘッダー画像は `site-header` 内でトリミング表示する仕様のため、画像自体の幅はコンテナより大きい。これは overflow バグとはみなさない。
- in-app browser 実行環境から `test_evidence` への PNG 直接保存は `EPERM` で失敗したため、今回は実測と目視確認を優先した。
- 客先向けの正式証跡は、必要なら別手段でスクリーンショット保存を行う。

## 判定
- **今回修正した `reserve.asp` の切替不具合については、in-app browser 上では再現せず、暫定的に解消確認。**
- ただし **正式な納品判定は未了**。
  - 理由:
    1. Chrome / Edge / Firefox 実機で境界幅再試験をまだやり直していない
    2. 機能回帰の未実施が残っている

## 次アクション
1. Chrome 実機で同じ境界幅を再試験
2. Edge 実機で同じ境界幅を再試験
3. Firefox 実機で同じ境界幅を再試験
4. 正式証跡を `test_evidence` に保存
5. 回帰結果集計を更新
