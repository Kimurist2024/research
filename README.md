# arXiv論文検索エンジン

Juliaで実装されたarXiv論文検索エンジンです。1200+の研究論文をインデックス化し、リアルタイムで検索できます。

## 機能

- TF-IDFベースの全文検索
- arXiv APIからの自動論文取得（1200+ 論文）
- コサイン類似度による関連度ランキング
- 複数CSカテゴリ対応（AI、ML、CL、CV、IR、stat.ML）
- レスポンシブWebインターフェース
- 30分間隔の自動論文更新
- ランダムポート自動選択（8000-9999）

## インストール

```bash
julia --project=.
```

Julia REPLで:
```julia
using Pkg
Pkg.instantiate()
```

## 起動方法

### 標準起動（ランダムポート）
```bash
cd research
julia server.jl
```

または、プロジェクトルートから：
```bash
julia research/server.jl
```

サーバー起動時にランダムなポート（8000-9999）が自動選択され、コンソールに表示されます。

### 特定ポート指定
```julia
# Julia REPLで
include("server.jl")
start_server(8080)  # ポート8080で起動
```

### バックグラウンド論文取得なしで起動
```julia
start_server(8080, false)  # 論文自動取得を無効化
```

## プロジェクト構造

```
research/
├── server.jl              # メインサーバー（エントリーポイント）
├── document.jl             # 文書とインデックス構造の定義
├── text_processing.jl      # テキスト処理（トークン化、TF計算）
├── search_engine.jl        # 検索エンジンコア（TF-IDF、類似度計算）
├── arxiv_client.jl         # arXiv API クライアント
├── paper_manager.jl        # 論文管理とバックグラウンド取得
└── web_interface.jl        # HTML テンプレート生成
```

## アーキテクチャ

- **検索エンジンコア**: TF-IDFベースの転置インデックス（`search_engine.jl`）
- **arXivクライアント**: 論文の自動取得と解析（`arxiv_client.jl`）
- **Webインターフェース**: HTMLベースの検索UI（`web_interface.jl`）
- **バックグラウンド更新**: 定期的な新論文の取得（`paper_manager.jl`）
- **モジュラー設計**: 機能ごとに分離された保守しやすい構造
