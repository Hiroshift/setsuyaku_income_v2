# 🌱 節約は収入

![紫　シンプル　アプリ　プレゼンテーション.png](attachment:6bd81945-d632-4369-83a3-ab1511e0dd01:紫_シンプル_アプリ_プレゼンテーション.png)

## 🚀 プロジェクト概要

**「節約は収入」** は、一般的な家計簿アプリではありません。「時間を取り戻す」夢のアプリです。皆さんが貴重な時間を使って得たお給料は、 時に浪費や無意識な消費に消えていきます。

このアプリは、浪費を防ぎ、節約したお金を「収入」そして「取り戻した時間」として換算。
目標や夢の実現に役立つリソースとして活用できる仕組みを提供します。

📌 **デモサイト:** [節約は収入](https://setsuyaku-income.onrender.com/)

📌 **ログイン情報:**

- **ID**：`s_admin`
- **PASS**：`s_1537`

## 🎯 開発の背景

### **なぜこのアプリを作ったのか？**

- **無意識化しやすい支出を意識化し、「働いて得た時間」の価値を実感するため**
- **無駄遣いを減らし、時間とお金を有意義に活用できるよう支援するため**
- **浪費が目標達成や時間活用に与える影響を具体的に見える化するため**

## 🖥️ 画面イメージ・機能一覧

### **📷 スクリーンショット**

![](https://your-image-url.com/dashboard.png)

## 🔍 競合製品との比較 (Comparison - 比較)

| 特徴 | 節約は収入 | 他の家計簿アプリ |
| --- | --- | --- |
| 節約を時給換算 | ✅ 可能 | ❌ なし |
| 目標管理機能 | 🔜 実装予定 | ❌ 一部サポート |
| AI提案機能 | 🔜 実装予定 | ❌ なし |
| コミュニティ機能 | 🔜 実装予定 | ✅ あり |
| シンプルなUI | ✅ あり | ❌ 複雑 |

## 🛠️ 使用技術

| カテゴリ | 技術 |
| --- | --- |
| 💻 フロントエンド | HTML / CSS / JavaScript / |
| 🔙 バックエンド | Ruby on Rails |
| 🗄️ データベース | PostgreSQL |
| ☁️ インフラ | Heroku |
| 🔧 開発ツール | Git / GitHub |

| カテゴリ | 技術 |
| --- | --- |
| 💻 フロントエンド | HTML / CSS / JavaScript / Bootstrap |
| 🔙 バックエンド | Ruby on Rails |
| 🗄️ データベース | PostgreSQL |
| ☁️ インフラ | Heroku |
| 🔧 開発ツール | Git / GitHub / Docker |

## 📜 ER図・システム構成図

![](https://chatgpt.com/mnt/data/ER.png)

## 📝 使い方

### **1. 初回設定 - 自分の時給を入力**

- アプリを利用する前に、自分の時給を設定します。
- **例:** 時給1,200円 → 600円節約すると0.5時間（30分）の労働時間を取り戻せる

### **2. 節約金額を記録**

- 不要な出費を控えたら、その金額をアプリに記録します。
- **例:** 節約「600円」→ 記録

### **3. 節約額を時給換算で表示**

- 節約した金額が「何時間分の労働に相当するか」を自動計算。
- **例:** 600円節約 → 30分の労働時間に相当（時給が1,200円の場合）

## 🔮 今後の展望

- **「節約と収入」のUI/UXを高め、より直感的で使いやすいアプリへ進化**
- **節約だけでなく、意識変革を促すアプリをシリーズ化し、多角的な視点で価値提供**
- **AIアシスタントによる節約アドバイスの提供**

## 👥 コントリビューション

このプロジェクトはオープンソースではありませんが、
フィードバックやアイデアの提供を歓迎します！

### **貢献の方法**

- **バグ報告:** GitHubのIssueを作成
- **改善提案:** フィードバックフォームより送信
- **コラボレーション:** コードやデザインの貢献を検討

✉ **ご意見・お問い合わせ:** hiroshift@example.com

## 📜 ライセンス

MIT License © Hiroshift 2025

# README

## テーブル設計

### Usersテーブル

| Column             | Type    | Options                   |
|--------------------|---------|---------------------------|
| nickname           | string  | null: false               |
| email              | string  | null: false, unique: true |
| encrypted_password | string  | null: false               |
| hourly_rate        | integer | null: false               |
| total_income       | integer | default: 0                |

#### Association
- has_many :recordings

---

### Recordingsテーブル

| Column         | Type       | Options                        |
|----------------|------------|--------------------------------|
| amount         | integer    | null: false                    |
| recorded_date  | date       | null: false                    |
| user           | references | null: false, foreign_key: true |
| created_at     | datetime   | null: false                    |
| updated_at     | datetime   | null: false                    |

#### Association
- belongs_to :user
