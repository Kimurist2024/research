# Julia Search Engine - arXiv論文検索システム

モジュール化された、読みやすいJulia実装の検索エンジンです。arXivから論文を自動取得し、TF-IDFベースの全文検索を提供します。

## 特徴

- 🔍 **高速な全文検索**: TF-IDFアルゴリズムによる関連性の高い検索
- 📚 **自動論文取得**: arXiv APIから最新論文を定期的に取得
- 🌐 **Webインターフェース**: ブラウザから簡単に検索可能
- 🔧 **REST API**: JSON形式でのAPI提供
- 📦 **モジュール設計**: 保守性と拡張性を考慮したクリーンな構造

## プロジェクト構造

```
julia_search_engine/
├── Project.toml          # 依存関係定義
├── config/
│   └── config.json       # 設定ファイル
├── src/
│   ├── main.jl          # メインエントリポイント
│   ├── models/          # データモデル
│   │   ├── Document.jl
│   │   └── Index.jl
│   ├── utils/           # ユーティリティ
│   │   ├── TextProcessor.jl
│   │   └── Similarity.jl
│   ├── core/            # コア機能
│   │   └── SearchEngine.jl
│   ├── services/        # 外部サービス
│   │   ├── ArxivClient.jl
│   │   └── PaperFetcher.jl
│   ├── web/             # Webサーバー
│   │   ├── Server.jl
│   │   ├── RequestHandler.jl
│   │   └── HTMLTemplates.jl
│   └── config/          # 設定管理
│       └── Config.jl
└── README.md
```

## インストールと起動

### 1. 依存関係のインストール

```bash
cd julia_search_engine
julia --project=.
```

Juliaの REPL で：
```julia
using Pkg
Pkg.instantiate()
```

### 2. サーバーの起動

```bash
julia --project=. src/main.jl
```

または、Julia REPL から：
```julia
include("src/main.jl")
using .JuliaSearchEngine
JuliaSearchEngine.start_application()
```

### 3. ブラウザでアクセス

```
http://localhost:8080
```

## 設定

`config/config.json` で設定をカスタマイズできます：

```json
{
  "server": {
    "port": 8080,
    "host": "0.0.0.0"
  },
  "fetcher": {
    "enabled": true,
    "interval": 1800,
    "categories": [
      "cs.AI",
      "cs.LG",
      "cs.CL",
      "cs.CV"
    ],
    "max_results": 200
  }
}
```

## API エンドポイント

### 検索API
```
GET /api/search?q=<query>&top_k=<number>
```

### ステータスAPI
```
GET /api/status
```

### インデックス更新
```
POST /api/index/update
```

## モジュール説明

### Document & Index
- ドキュメントとインデックスのデータ構造を定義
- 転置インデックスによる高速検索を実現

### TextProcessor
- テキストのトークン化
- TF（単語頻度）計算
- TF-IDF計算

### Similarity
- コサイン類似度
- Jaccard類似度
- ユークリッド距離

### SearchEngine
- 検索エンジンのコア機能
- インデックス管理
- クエリ処理と検索実行

### ArxivClient
- arXiv API との通信
- XMLレスポンスのパース
- 論文データの取得

### PaperFetcher
- 定期的な論文取得
- バックグラウンドタスク管理
- 取得状態の監視

### Server & RequestHandler
- HTTPサーバー管理
- リクエストルーティング
- レスポンス生成

### HTMLTemplates
- HTMLページの生成
- 検索結果の表示
- レスポンシブデザイン

## ライセンス

MIT License