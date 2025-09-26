# arXiv論文検索エンジン

Juliaで実装されたarXiv論文検索エンジンです。1200+の研究論文をインデックス化し、リアルタイムで検索できます。

## 機能

- TF-IDFベースの全文検索
- arXiv APIからの自動論文取得（1200+ 論文）
- コサイン類似度による関連度ランキング
- 複数CSカテゴリ対応（AI、ML、CL、CV、IR、stat.ML）
- レスポンシブWebインターフェース
- 30分間隔の自動論文更新

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
julia webapp_enhanced.jl
```

ブラウザで `http://localhost:8004` にアクセス

## アーキテクチャ

- **検索エンジンコア**: TF-IDFベースの転置インデックス
- **arXivクライアント**: 論文の自動取得と解析
- **Webインターフェース**: HTMLベースの検索UI
- **バックグラウンド更新**: 定期的な新論文の取得
