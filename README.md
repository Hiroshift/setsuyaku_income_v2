# 節約は収入

「節約した金額」を「収入」として可視化し、  
それが何分ぶんの**労働**に相当するかを知るアプリ。

## コンセプト

> 節約は、我慢ではない。意識的な選択だ。

家計簿アプリではありません。  
「お金を使わなかった」という行為を「収入を得た」と捉え直し、  
その収入が **自分の労働時間の何分に相当するか** を可視化します。

**例：** 時給1,200円の人がコンビニ弁当をやめて自炊 → ¥500の節約 = **25分ぶんの労働**

## 主な機能

| 機能 | 説明 |
|---|---|
| 電卓式入力 | スマホに最適化したワンタップ記録 |
| 労働時間換算 | 節約額を「何分ぶんの労働か」に自動変換 |
| 日付選択 | 過去7日間の記録に対応 |
| メモ機能 | 何を節約したかを記録 |
| 累計表示 | これまでの節約収入と労働時間の合計 |
| 連続記録 | 連続記録日数の表示 |
| 週次サマリー | 今週の節約収入と前週比 |
| 履歴ページ | 月別集計・具体的な体験換算 |
| AI提案 | Gemini APIによる「この時間で何ができる？」提案 |
| 年間予測 | 年末までの節約ペース予測 |
| PWA対応 | ホーム画面に追加してアプリとして使用可能 |
| フリーミアム | 無料で基本機能、プレミアムで深い分析 |

## 使用技術

| カテゴリ | 技術 |
|---|---|
| バックエンド | Ruby 3.2.0 / Rails 7.0 |
| フロントエンド | HTML / CSS / JavaScript / Hotwire (Turbo + Stimulus) |
| データベース | MySQL（開発） / PostgreSQL（本番） |
| 認証 | Devise |
| AI | Google Gemini API |
| インフラ | Render |
| テスト | RSpec / FactoryBot / Faker |
| PWA | Service Worker / Web App Manifest |

## セットアップ

```bash
git clone https://github.com/your-username/setsuyaku_income_v2.git
cd setsuyaku_income_v2
bundle install
rails db:create db:migrate
```

### 環境変数（`.env` ファイル）

```
BASIC_AUTH_USER_SETSUYAKU=your_username
BASIC_AUTH_PASSWORD_SETSUYAKU=your_password
GEMINI_API_KEY=your_api_key
```

### サーバー起動

```bash
bin/rails server
```

## テスト

```bash
bundle exec rspec
```

89テスト（モデル・リクエスト・ロジック）

## テーブル設計

### Users テーブル

| Column | Type | Options |
|---|---|---|
| nickname | string | null: false |
| email | string | null: false, unique: true |
| encrypted_password | string | null: false |
| hourly_rate | integer | null: false |
| total_income | integer | default: 0 |
| premium | boolean | default: false, null: false |

#### Association
- has_many :recordings, dependent: :destroy

### Recordings テーブル

| Column | Type | Options |
|---|---|---|
| amount | integer | null: false |
| recorded_date | date | null: false |
| note | string | |
| user | references | null: false, foreign_key: true |

#### Association
- belongs_to :user

## ライセンス

MIT License © 2025-2026
