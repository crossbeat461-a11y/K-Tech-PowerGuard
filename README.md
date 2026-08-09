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

> **インストール前に必ずお読みください（日本語）** — 下記「インストールに関する免責・同意」。DMG からインストールした時点で同意したものとみなします。

### インストールに関する免責・同意

- 本ソフトウェア（K-Tech PowerGuard）の **ダウンロード・インストール・利用は、すべて利用者自身の判断と責任** で行ってください。
- **お使いの Mac の環境（macOS のバージョン、機種、セキュリティ設定、通知設定、ログイン項目、他アプリとの競合など）によっては、インストールできない、起動しない、通知が出ない、期待どおり動作しない** 場合があります。開発者は **すべての環境での動作を保証しません**。
- 開発者（K-Tech Studio）は、**インストールの成功、継続的な正常動作、通知の到達、バッテリー寿命・本体・データへの影響** などについて、**いかなる保証も行いません**。
- **DMG からインストールする、または本ソフトウェアを利用開始した時点で**、上記および [MIT ライセンス](LICENSE) の内容を **理解し、同意したもの** とみなします。
- 本ソフトウェアの利用（インストールを含む）に関連して生じた **いかなる損害・不利益** についても、開発者・著作権者は **MIT ライセンスおよび適用される法令の範囲内でのみ** 責任を負い、それを超える責任の追及は受けません。

**まだ Release が無い場合** — この Mac で DMG を作る（要 Xcode ライセンス同意）:

```bash
sudo xcodebuild -license accept
cd "/Users/kimurashigeru/Documents/github/K-Tech PowerGuard"
./scripts/build-dmg.sh
```

→ `dist/K-Tech-PowerGuard-1.0.0.dmg` ができます。詳細は [dist/ビルド手順.txt](dist/ビルド手順.txt)

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

---

## Disclaimer (English)

> **Read before install** — By installing from the DMG or using this software, you agree to the terms below and the [MIT License](LICENSE).

**Installation and use — no warranty**

- You **download, install, and use** K-Tech PowerGuard **at your own risk and responsibility**.
- **Depending on your Mac environment** (macOS version, hardware model, security settings, notification settings, login items, conflicts with other apps, etc.), the app **may fail to install, fail to launch, fail to notify, or not behave as expected**. The developer **does not guarantee operation in every environment**.
- The developer (K-Tech Studio) **does not warrant** successful installation, ongoing correct operation, delivery of notifications, or any effect on battery life, hardware, or data.
- **By installing from the DMG or starting to use the software**, you **acknowledge and agree** to this disclaimer and the MIT License.
- To the **maximum extent permitted by applicable law**, the authors and copyright holders **shall not be liable** for any damages or losses arising from installation or use of this software, except as stated in the MIT License.
