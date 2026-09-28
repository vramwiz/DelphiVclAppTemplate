# 登録ライブラリ一覧

運用方針は [note.md](../note.md) を参照する。
登録済みのライブラリは以下のとおり。実ホストでの確認状況も参照する。

## 登録時の記載方法

各登録物を次の表へ追加する。概要は短くし、詳しい依存関係・コピー対象・導入方法・テスト手順は各登録物の説明Markdownへリンクする。
利用するプロジェクト側が、必要な登録物を選択・コピーして組み込む。

| ID・名称 | 種別 | 用途・タグ | 版 | 説明・保存場所 | 最小テストプロジェクト | 確認状況 |
| --- | --- | --- | --- | --- | --- | --- |
| vertical-scrollbar / 独自縦スクロールバー | UI部品 | VCL・暗色UI・縦スクロール・一覧・パネル | 1.0.0 | [説明・ソース](UI/VerticalScrollBar/README.md) | [スクロールバーテスト](../VerticalScrollBarTest.dproj) | Debug/Releaseビルド成功、実操作未確認 |
| aviutl2-canvas / AviUtl2背景キャンバス | キット | AviUtl2・SYNC・GPU背景・パン・ズーム・設定保存 | 1.0.0 | [説明・ソース](Kits/AviUtl2Canvas/README.md) | [フィルタープラグイン](../SYNC_CanvasTest_Filter.dproj) | Debug/Release・自動テスト成功、実ホストUI未確認 |
