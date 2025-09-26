# Julia検索エンジン

Juliaで実装されたシンプルな検索エンジンとWebインターフェースです。

## 機能

- TF-IDFベースの文書インデックス作成
- コサイン類似度による検索ランキング
- タイトルマッチングによるスコアブースト
- レスポンシブWebインターフェース

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

```bash
julia --project=. webapp.jl
```

ブラウザで `http://localhost:8080` にアクセス

## アーキテクチャ

- **SearchEngine.jl**: 検索エンジンのコア機能
  - Document構造体: 文書データ
  - Index構造体: 転置インデックスとTF-IDF情報
  - search関数: クエリ処理と結果ランキング

- **webapp.jl**: Webアプリケーション
  - HTTPサーバー
  - HTMLテンプレート
  - 検索リクエスト処理