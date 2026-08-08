# K-Tech PowerGuard

MacBook Neo の4色（**Silver · Blush · Citrus · Indigo**）に合わせた、メニューバー常駐のバッテリー通知アプリです。無償配布（MIT）。

## 機能

- **下限（デフォルト 20%）** — バッテリー駆動で下回ったら「充電を検討」の通知
- **上限（デフォルト 80%）** — 充電中に上回ったら「コンセントを外す」通知（充電の物理停止は macOS では行いません）
- しきい値は設定画面で変更可能
- **表示言語:** 日本語（初期値） / English（設定で切替）
- **MacBook Neo 4色** をワンタップで切替 + カスタムアクセント色
- **ログイン時に起動**（設定で ON/OFF）
- **Apple Watch** — Mac の通知を Watch に表示する設定がオンなら届くことがあります（専用 Watch アプリはありません）

## ダウンロード

[GitHub Releases](https://github.com/crossbeat461-a11y/K-Tech-PowerGuard/releases) から `K-Tech-PowerGuard-1.0.0.dmg`（最新版）を取得してください。

1. DMG を開く  
2. **K-Tech PowerGuard** を **Applications** にドラッグ  
3. 初回起動: 右クリック → **開く**（未署名ビルドの場合）  
4. **システム設定 → 通知** で K-Tech PowerGuard を許可  
5. メニューバーアイコン → **設定…** で Neo カラー・しきい値を調整  

## ビルド（開発者向け）

```bash
# Xcode ライセンス同意後
cd "K-Tech PowerGuard"
./scripts/build-dmg.sh
# → dist/K-Tech-PowerGuard-1.0.0.dmg
```

Xcode 26 / macOS 14 以上を想定。`K-Tech PowerGuard.xcodeproj` を開いて Run も可能です。

## MacBook Neo カラー

| プリセット | 用途 |
|-----------|------|
| Silver | 初期値（シルバー Neo） |
| Blush | ブラッシュ |
| Citrus | シトラス |
| Indigo | インディゴ |

## ライセンス

MIT — 詳細は [LICENSE](LICENSE)
