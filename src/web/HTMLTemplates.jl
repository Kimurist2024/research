module HTMLTemplates

using ..SearchEngine
using ..UserManager

export render_home, render_search_results, render_advanced_search, render_image_search, render_news_page, render_settings_page, render_user_page

"""
    render_home()

ホームページのHTMLを生成
"""
function render_home()
    index = SearchEngine.get_global_index()
    doc_count = length(index.documents)

    return """
    <!DOCTYPE html>
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Julia Search Engine - arXiv論文検索</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    </head>
    <body>
        <!-- Header Navigation -->
        <header class="main-header">
            <div class="header-container">
                <div class="logo">
                    <i class="fas fa-search"></i>
                    <span>Julia検索エンジン</span>
                </div>
                <nav class="main-nav">
                    <a href="/" class="nav-link">ホーム</a>
                    <a href="/advanced" class="nav-link">詳細検索</a>
                    <a href="/images" class="nav-link">画像</a>
                    <a href="/news" class="nav-link">ニュース</a>
                    <a href="/settings" class="settings-btn"><i class="fas fa-cog"></i></a>
                    <a href="/user" class="user-avatar">
                        <i class="fas fa-user-circle"></i>
                    </a>
                </nav>
            </div>
        </header>

        <!-- Main Content -->
        <main class="main-content">
            <!-- Search Section -->
            <section class="search-section">
                <div class="search-icon-large">
                    <i class="fas fa-search"></i>
                </div>
                <h1 class="search-title">arXiv論文検索エンジン</h1>
                <p class="search-subtitle">最新の研究論文を高度なフィルタリングと即座の結果で検索</p>

                <div class="search-container">
                    <form action="/search" method="get">
                        <div class="search-box">
                            <input type="text" name="q" placeholder="検索キーワードを入力してください..." class="search-input" autofocus required>
                            <button type="submit" class="search-button">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </form>
                    <div class="search-options">
                        <button class="option-btn" onclick="document.querySelector('form').submit()">
                            <i class="fas fa-search"></i> 検索
                        </button>
                        <button class="option-btn" onclick="performLuckySearch()">
                            <i class="fas fa-dice"></i> ランダム検索
                        </button>
                    </div>
                </div>
            </section>

            <!-- Filters Section -->
            <section class="filters-section">
                <h2 class="filters-title">検索フィルタ</h2>
                <div class="filters-container">
                    <div class="filter-group">
                        <label for="contentType">コンテンツタイプ</label>
                        <select id="contentType" class="filter-select">
                            <option value="all">すべてのコンテンツ</option>
                            <option value="web">Webページ</option>
                            <option value="images">画像</option>
                            <option value="videos">動画</option>
                            <option value="news">ニュース</option>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label for="dateRange">期間</label>
                        <select id="dateRange" class="filter-select">
                            <option value="anytime">すべての期間</option>
                            <option value="hour">過去1時間</option>
                            <option value="day">過去24時間</option>
                            <option value="week">過去1週間</option>
                            <option value="month">過去1か月</option>
                            <option value="year">過去1年</option>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label for="language">言語</label>
                        <select id="language" class="filter-select">
                            <option value="any">すべての言語</option>
                            <option value="en">英語</option>
                            <option value="ja">日本語</option>
                            <option value="es">スペイン語</option>
                            <option value="fr">フランス語</option>
                            <option value="de">ドイツ語</option>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label for="region">地域</label>
                        <select id="region" class="filter-select">
                            <option value="worldwide">世界</option>
                            <option value="us">アメリカ</option>
                            <option value="uk">イギリス</option>
                            <option value="jp">日本</option>
                            <option value="eu">ヨーロッパ</option>
                        </select>
                    </div>
                </div>
            </section>

            <!-- Sample Results Section -->
            <section class="results-section">
                <div class="results-container">
                    <div class="result-card">
                        <div class="result-icon web">
                            <i class="fas fa-globe"></i>
                        </div>
                        <div class="result-content">
                            <a href="#" class="result-title">研究論文のサンプルタイトル</a>
                            <div class="result-url">https://arxiv.org/abs/2024.0001</div>
                            <div class="result-description">これは検索結果の表示方法を示すサンプルの研究論文説明です。機械学習と自然言語処理の最新手法について詳しく解説しています。</div>
                            <div class="result-meta">
                                <span class="result-meta-item">
                                    <i class="far fa-calendar"></i>
                                    2025年1月15日
                                </span>
                                <span class="result-meta-item">
                                    <i class="far fa-eye"></i>
                                    1.2K 閲覧
                                </span>
                                <span class="result-meta-item rating">
                                    <i class="fas fa-star"></i>
                                    4.1 評価
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="result-card">
                        <div class="result-icon image">
                            <i class="fas fa-image"></i>
                        </div>
                        <div class="result-content">
                            <a href="#" class="result-title">深層学習による画像認識に関する研究</a>
                            <div class="result-url">https://arxiv.org/abs/2024.0002</div>
                            <div class="result-description">コンピュータビジョンと深層学習技術を組み合わせた最新の画像認識手法について論じた研究論文です。従来手法との比較と性能評価を詳細に示しています。</div>
                            <div class="result-meta">
                                <span class="result-meta-item">
                                    <i class="far fa-calendar"></i>
                                    2025年1月12日
                                </span>
                                <span class="result-meta-item">
                                    <i class="far fa-eye"></i>
                                    856 閲覧
                                </span>
                                <span class="result-meta-item rating">
                                    <i class="fas fa-star"></i>
                                    4.2 評価
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="result-card">
                        <div class="result-icon video">
                            <i class="fas fa-video"></i>
                        </div>
                        <div class="result-content">
                            <a href="#" class="result-title">強化学習とゲーム理論の統合的アプローチ</a>
                            <div class="result-url">https://arxiv.org/abs/2024.0003</div>
                            <div class="result-description">マルチエージェント環境における強化学習の新しいアプローチを提案する研究です。ゲーム理論と組み合わせることで、より効率的な学習アルゴリズムを実現しています。</div>
                            <div class="result-meta">
                                <span class="result-meta-item">
                                    <i class="far fa-calendar"></i>
                                    2025年1月10日
                                </span>
                                <span class="result-meta-item">
                                    <i class="far fa-eye"></i>
                                    5.2K 閲覧
                                </span>
                                <span class="result-meta-item rating">
                                    <i class="fas fa-star"></i>
                                    4.8 評価
                                </span>
                                <span class="result-meta-item">
                                    <i class="far fa-clock"></i>
                                    ページ数: 23
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Pagination -->
                <div class="pagination">
                    <button class="page-btn prev" disabled>←</button>
                    <button class="page-btn active">1</button>
                    <button class="page-btn">2</button>
                    <button class="page-btn">3</button>
                    <button class="page-btn">4</button>
                    <button class="page-btn">5</button>
                    <button class="page-btn next">→</button>
                </div>
            </section>
        </main>

        <!-- Footer -->
        <footer class="main-footer">
            <div class="footer-container">
                <div class="footer-section">
                    <h3>概要</h3>
                    <ul>
                        <li><a href="#">検索の仕組み</a></li>
                        <li><a href="#">プロジェクトについて</a></li>
                        <li><a href="#">開発情報</a></li>
                    </ul>
                </div>

                <div class="footer-section">
                    <h3>サポート</h3>
                    <ul>
                        <li><a href="#">ヘルプセンター</a></li>
                        <li><a href="#">お問い合わせ</a></li>
                        <li><a href="#">フィードバック</a></li>
                    </ul>
                </div>

                <div class="footer-section">
                    <h3>法的事項</h3>
                    <ul>
                        <li><a href="#">プライバシーポリシー</a></li>
                        <li><a href="#">利用規約</a></li>
                        <li><a href="#">クッキーポリシー</a></li>
                    </ul>
                </div>

                <div class="footer-section">
                    <h3>つながり</h3>
                    <div class="social-links">
                        <a href="#" class="social-link"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-facebook"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
                    </div>
                </div>
            </div>

            <div class="footer-bottom">
                <p>&copy; 2025 Julia検索エンジン. すべての権利を保有.</p>
            </div>
        </footer>

        <style>
            $(get_google_style_css())
        </style>

        <script>
            function performLuckySearch() {
                const query = document.querySelector('.search-input').value.trim();
                if (query) {
                    window.location.href = '/search?q=' + encodeURIComponent(query) + '&lucky=1';
                }
            }
        </script>
    </body>
    </html>
    """
end

"""
    render_search_results(query::String, results::Vector{SearchResult})

検索結果ページのHTMLを生成
"""
function render_search_results(query::String, results::Vector{SearchResult})
    index = SearchEngine.get_global_index()
    doc_count = length(index.documents)

    # 結果のHTML生成
    results_html = if isempty(results)
        """
        <div class="no-results">
            <h3>検索結果が見つかりませんでした</h3>
            <p>「$(query)」に一致する論文は見つかりませんでした。</p>
            <ul>
                <li>キーワードを変更してみてください</li>
                <li>より一般的な用語を使用してください</li>
                <li>英語での検索を試してください</li>
            </ul>
        </div>
        """
    else
        join([render_result(r) for r in results], "\n")
    end

    return """
    <!DOCTYPE html>
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>「$(query)」の検索結果 - Julia Search Engine</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    </head>
    <body>
        <!-- Header Navigation -->
        <header class="main-header">
            <div class="header-container">
                <div class="logo">
                    <i class="fas fa-search"></i>
                    <a href="/" style="color: inherit; text-decoration: none;"><span>Julia検索エンジン</span></a>
                </div>
                <nav class="main-nav">
                    <a href="/" class="nav-link">ホーム</a>
                    <a href="/advanced" class="nav-link">詳細検索</a>
                    <a href="/images" class="nav-link">画像</a>
                    <a href="/news" class="nav-link">ニュース</a>
                    <a href="/settings" class="settings-btn"><i class="fas fa-cog"></i></a>
                    <a href="/user" class="user-avatar">
                        <i class="fas fa-user-circle"></i>
                    </a>
                </nav>
            </div>
        </header>

        <!-- Main Content -->
        <main class="main-content">
            <!-- Search Section -->
            <section class="search-section-compact">
                <div class="search-container">
                    <form action="/search" method="get">
                        <div class="search-box">
                            <input type="text" name="q" value="$(query)" placeholder="検索キーワードを入力してください..." class="search-input" required>
                            <button type="submit" class="search-button">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </form>
                </div>

                <div class="results-info-section">
                    <p class="results-count">「<strong>$(query)</strong>」の検索結果: $(length(results))件</p>
                    <p class="index-info">総インデックス数: $(doc_count)件の論文</p>
                </div>
            </section>

            <!-- Results Section -->
            <section class="results-section">
                <div class="results-container">
                    $(results_html)
                </div>
            </section>
        </main>

        <!-- Footer -->
        <footer class="main-footer">
            <div class="footer-container">
                <div class="footer-section">
                    <h3>概要</h3>
                    <ul>
                        <li><a href="#">検索の仕組み</a></li>
                        <li><a href="#">プロジェクトについて</a></li>
                        <li><a href="#">開発情報</a></li>
                    </ul>
                </div>

                <div class="footer-section">
                    <h3>サポート</h3>
                    <ul>
                        <li><a href="#">ヘルプセンター</a></li>
                        <li><a href="#">お問い合わせ</a></li>
                        <li><a href="#">フィードバック</a></li>
                    </ul>
                </div>

                <div class="footer-section">
                    <h3>法的事項</h3>
                    <ul>
                        <li><a href="#">プライバシーポリシー</a></li>
                        <li><a href="#">利用規約</a></li>
                        <li><a href="#">クッキーポリシー</a></li>
                    </ul>
                </div>

                <div class="footer-section">
                    <h3>つながり</h3>
                    <div class="social-links">
                        <a href="#" class="social-link"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-facebook"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
                    </div>
                </div>
            </div>

            <div class="footer-bottom">
                <p>&copy; 2025 Julia検索エンジン. すべての権利を保有.</p>
            </div>
        </footer>

        <style>
            $(get_google_style_css())

            /* Additional styles for search results page */
            .search-section-compact {
                padding: 2rem 1rem 1rem;
                border-bottom: 1px solid var(--border-color);
                background-color: var(--bg-white);
            }

            .search-section-compact .search-container {
                max-width: 650px;
                margin: 0 auto;
            }

            .results-info-section {
                max-width: 900px;
                margin: 1.5rem auto 0;
                padding: 0 1rem;
            }

            .results-count {
                font-size: 1rem;
                color: var(--text-dark);
                margin-bottom: 0.25rem;
            }

            .index-info {
                font-size: 0.875rem;
                color: var(--text-light);
            }

            .results-section {
                max-width: 900px;
                margin: 0 auto;
                padding: 1rem;
            }

            .results-container {
                max-width: 600px;
                margin: 0;
                padding: 0;
            }

            /* Google Search Results Exact Recreation */
            .g {
                margin-bottom: 30px;
                max-width: 600px;
                line-height: 1.58;
            }

            .tF2Cxc {
                margin-bottom: 0;
            }

            .yuRUbf {
                margin-bottom: 4px;
            }

            .yuRUbf a {
                text-decoration: none;
            }

            .LC20lb.DKV0Md {
                color: #1a0dab;
                font-size: 20px;
                line-height: 1.3;
                margin: 0;
                font-weight: 400;
                display: inline-block;
                cursor: pointer;
            }

            .LC20lb.DKV0Md:hover {
                text-decoration: underline;
            }

            .LC20lb.DKV0Md:visited {
                color: #681da8;
            }

            .byrV5b {
                margin-bottom: 8px;
            }

            .qLRx3b.tjvcx {
                color: #006621;
                font-size: 14px;
                font-style: normal;
                line-height: 16px;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                max-width: 600px;
            }

            .Z26q7c.UK95Uc {
                margin-bottom: 4px;
            }

            .VwiC3b.yXK7lf.MUxGbd.yDYNvb.lyLwlc.lEBKkf {
                color: #4d5156;
                font-size: 14px;
                line-height: 1.58;
            }

            .MUxGbd.wuQ4Ob.WZ8Tjf {
                color: #4d5156;
                font-size: 14px;
            }

            .kb0PBd.cvP2Ce {
                margin-top: 4px;
            }

            .VwiC3b.yXK7lf.MUxGbd.yDYNvb.lyLwlc {
                color: #4d5156;
                font-size: 14px;
                line-height: 1.58;
            }

            .hgKElc {
                color: #4d5156;
                font-size: 14px;
                line-height: 1.58;
            }

            /* Results section adjustments */
            .results-section {
                max-width: 652px;
                margin: 0;
                padding: 20px 0 0 165px;
            }

            /* Favorite button styling */
            .result-title-row {
                display: flex;
                align-items: flex-start;
                gap: 0.5rem;
            }

            .result-title-row a {
                flex: 1;
            }

            .favorite-btn {
                background: none;
                border: none;
                color: #ffa500;
                font-size: 1rem;
                cursor: pointer;
                padding: 0.25rem;
                border-radius: 4px;
                transition: all 0.2s ease;
                opacity: 0.7;
                margin-top: 2px;
            }

            .favorite-btn:hover {
                opacity: 1;
                background-color: rgba(255, 165, 0, 0.1);
            }

            .favorite-btn .fas {
                color: #ffa500;
            }

            .favorite-btn .far {
                color: #999;
            }

            @media (max-width: 768px) {
                .results-section {
                    padding: 20px 16px 0 16px;
                }

                .g {
                    margin-bottom: 24px;
                }

                .LC20lb.DKV0Md {
                    font-size: 18px;
                }
            }
        </style>

        <script>
            async function toggleFavorite(url, title) {
                try {
                    const button = event.target.closest('.favorite-btn');
                    const icon = button.querySelector('i');
                    const isFavorited = icon.classList.contains('fas');

                    if (isFavorited) {
                        // Remove from favorites
                        const response = await fetch('/api/favorites/remove', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ url: url })
                        });

                        if (response.ok) {
                            icon.className = 'far fa-star';
                            button.title = 'お気に入りに追加';
                        } else {
                            alert('お気に入りの削除に失敗しました');
                        }
                    } else {
                        // Add to favorites
                        const response = await fetch('/api/favorites/add', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ url: url, title: title })
                        });

                        if (response.ok) {
                            icon.className = 'fas fa-star';
                            button.title = 'お気に入りから削除';
                        } else {
                            alert('お気に入りの追加に失敗しました');
                        }
                    }
                } catch (error) {
                    console.error('Error toggling favorite:', error);
                    alert('エラーが発生しました');
                }
            }
        </script>
    </body>
    </html>
    """
end

"""
    render_result(result::SearchResult)

個別の検索結果をHTMLで表示
"""
function render_result(result::SearchResult)
    # arXivかどうか判定
    is_arxiv = occursin("arxiv.org", result.url)

    # コンテンツプレビュー（短めに）
    content_preview = if length(result.content) > 160
        result.content[1:160] * "..."
    else
        result.content
    end

    # URLの表示用（短縮）
    display_url = result.url
    if length(display_url) > 60
        display_url = display_url[1:60] * "..."
    end

    # お気に入り状態を確認
    is_favorited = UserManager.is_favorite(result.url)
    favorite_icon = is_favorited ? "fas fa-star" : "far fa-star"
    favorite_title = is_favorited ? "お気に入りから削除" : "お気に入りに追加"

    # メタデータ処理
    metadata_items = []

    if haskey(result.metadata, "published")
        push!(metadata_items, result.metadata["published"])
    end

    if haskey(result.metadata, "authors") && !isempty(result.metadata["authors"])
        authors = join(result.metadata["authors"][1:min(2, length(result.metadata["authors"]))], ", ")
        if length(result.metadata["authors"]) > 2
            authors *= " et al."
        end
        push!(metadata_items, authors)
    end

    if haskey(result.metadata, "categories") && !isempty(result.metadata["categories"])
        categories = join(result.metadata["categories"], ", ")
        push!(metadata_items, categories)
    end

    return """
    <div class="g">
        <div class="tF2Cxc">
            <div class="yuRUbf">
                <div class="result-title-row">
                    <a href="$(result.url)" target="_blank">
                        <h3 class="LC20lb DKV0Md">$(result.title)</h3>
                    </a>
                    <button class="favorite-btn" onclick="toggleFavorite('$(result.url)', '$(replace(result.title, "'" => "\\'"))')" title="$(favorite_title)">
                        <i class="$(favorite_icon)"></i>
                    </button>
                </div>
                <div class="byrV5b">
                    <cite class="qLRx3b tjvcx">$(display_url)</cite>
                </div>
            </div>
            <div class="Z26q7c UK95Uc">
                <div class="VwiC3b yXK7lf MUxGbd yDYNvb lyLwlc lEBKkf">
                    <span class="MUxGbd wuQ4Ob WZ8Tjf">
                        $(join(metadata_items, " · "))
                    </span>
                </div>
            </div>
            <div class="kb0PBd cvP2Ce" data-sncf="1" data-snf="nke7rc">
                <div class="VwiC3b yXK7lf MUxGbd yDYNvb lyLwlc">
                    <span class="hgKElc">$(content_preview)</span>
                </div>
            </div>
        </div>
    </div>
    """
end

"""
    get_google_style_css()

Google風のCSSスタイルを返す
"""
function get_google_style_css()
    return """
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    :root {
        --primary-color: #4285f4;
        --secondary-color: #34a853;
        --danger-color: #ea4335;
        --warning-color: #fbbc05;
        --text-dark: #202124;
        --text-light: #5f6368;
        --bg-light: #f8f9fa;
        --bg-white: #ffffff;
        --border-color: #dadce0;
        --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
        --shadow-md: 0 2px 6px rgba(0,0,0,0.1);
        --shadow-lg: 0 4px 12px rgba(0,0,0,0.15);
    }

    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        color: var(--text-dark);
        background-color: var(--bg-white);
        line-height: 1.6;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
    }

    .main-content {
        flex: 1;
        padding: 2rem 1rem;
        max-width: 1400px;
        margin: 0 auto;
        width: 100%;
    }

    /* Header */
    .main-header {
        background-color: var(--bg-white);
        border-bottom: 1px solid var(--border-color);
        position: sticky;
        top: 0;
        z-index: 100;
        box-shadow: var(--shadow-sm);
    }

    .header-container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 1rem 2rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .logo {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        font-size: 1.25rem;
        font-weight: 600;
        color: var(--text-dark);
    }

    .logo i {
        color: var(--primary-color);
    }

    .main-nav {
        display: flex;
        align-items: center;
        gap: 1.5rem;
    }

    .nav-link {
        color: var(--text-dark);
        font-size: 0.875rem;
        font-weight: 500;
        padding: 0.5rem 0.75rem;
        border-radius: 4px;
        transition: background-color 0.2s;
        text-decoration: none;
    }

    .nav-link:hover {
        background-color: var(--bg-light);
    }

    .settings-btn {
        font-size: 1.25rem;
        color: var(--text-light);
        padding: 0.5rem;
        border-radius: 50%;
        transition: background-color 0.2s;
        background: none;
        border: none;
        cursor: pointer;
    }

    .settings-btn:hover {
        background-color: var(--bg-light);
    }

    .user-avatar {
        font-size: 1.75rem;
        color: var(--text-light);
        border-radius: 50%;
        transition: opacity 0.2s;
        text-decoration: none;
        display: flex;
        align-items: center;
        justify-content: center;
        width: 40px;
        height: 40px;
    }

    .user-avatar:hover {
        opacity: 0.8;
        background-color: var(--bg-light);
    }

    /* Search Section */
    .search-section {
        text-align: center;
        padding: 4rem 1rem 2rem;
    }

    .search-icon-large {
        font-size: 4rem;
        color: var(--text-light);
        margin-bottom: 1.5rem;
    }

    .search-title {
        font-size: 2.5rem;
        font-weight: 400;
        margin-bottom: 0.5rem;
        color: var(--text-dark);
    }

    .search-subtitle {
        font-size: 1rem;
        color: var(--text-light);
        margin-bottom: 2.5rem;
    }

    .search-container {
        max-width: 650px;
        margin: 0 auto;
    }

    .search-box {
        display: flex;
        align-items: center;
        background-color: var(--bg-white);
        border: 1px solid var(--border-color);
        border-radius: 24px;
        padding: 0.75rem 1rem;
        transition: box-shadow 0.2s;
        margin-bottom: 1.5rem;
    }

    .search-box:hover,
    .search-box:focus-within {
        box-shadow: var(--shadow-md);
        border-color: transparent;
    }

    .search-input {
        flex: 1;
        border: none;
        outline: none;
        font-size: 1rem;
        padding: 0 0.5rem;
        color: var(--text-dark);
    }

    .search-input::placeholder {
        color: var(--text-light);
    }

    .search-button {
        background-color: var(--text-dark);
        color: white;
        padding: 0.5rem 1.25rem;
        border-radius: 20px;
        border: none;
        font-size: 1rem;
        transition: background-color 0.2s;
        cursor: pointer;
    }

    .search-button:hover {
        background-color: #303134;
    }

    .search-options {
        display: flex;
        justify-content: center;
        gap: 1rem;
    }

    .option-btn {
        padding: 0.625rem 1.25rem;
        background-color: var(--bg-light);
        color: var(--text-dark);
        border-radius: 4px;
        font-size: 0.875rem;
        font-weight: 500;
        transition: all 0.2s;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        border: none;
        cursor: pointer;
    }

    .option-btn:hover {
        box-shadow: var(--shadow-sm);
        background-color: #f1f3f4;
    }

    /* Filters */
    .filters-section {
        max-width: 900px;
        margin: 2rem auto;
        padding: 0 1rem;
    }

    .filters-title {
        font-size: 1.25rem;
        font-weight: 500;
        margin-bottom: 1.25rem;
        color: var(--text-dark);
    }

    .filters-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 1rem;
    }

    .filter-group {
        display: flex;
        flex-direction: column;
    }

    .filter-group label {
        font-size: 0.875rem;
        color: var(--text-light);
        margin-bottom: 0.5rem;
        font-weight: 500;
    }

    .filter-select {
        padding: 0.625rem 0.75rem;
        border: 1px solid var(--border-color);
        border-radius: 4px;
        background-color: var(--bg-white);
        color: var(--text-dark);
        font-size: 0.875rem;
        cursor: pointer;
        transition: all 0.2s;
    }

    .filter-select:hover {
        border-color: var(--text-light);
    }

    .filter-select:focus {
        outline: none;
        border-color: var(--primary-color);
        box-shadow: 0 0 0 2px rgba(66, 133, 244, 0.1);
    }

    /* Results */
    .results-section {
        max-width: 900px;
        margin: 3rem auto;
        padding: 0 1rem;
    }

    .results-container {
        display: flex;
        flex-direction: column;
        gap: 1.5rem;
    }

    .result-card {
        background-color: var(--bg-white);
        border: 1px solid var(--border-color);
        border-radius: 8px;
        padding: 1.5rem;
        transition: box-shadow 0.2s;
        display: flex;
        gap: 1rem;
    }

    .result-card:hover {
        box-shadow: var(--shadow-md);
    }

    .result-icon {
        flex-shrink: 0;
        width: 48px;
        height: 48px;
        background-color: var(--bg-light);
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.25rem;
        color: var(--text-light);
    }

    .result-icon.web {
        background-color: #e8f0fe;
        color: var(--primary-color);
    }

    .result-icon.image {
        background-color: #e6f4ea;
        color: var(--secondary-color);
    }

    .result-icon.video {
        background-color: #fce8e6;
        color: var(--danger-color);
    }

    .result-content {
        flex: 1;
    }

    .result-title {
        font-size: 1.125rem;
        font-weight: 500;
        color: var(--primary-color);
        margin-bottom: 0.25rem;
        display: block;
        text-decoration: none;
    }

    .result-title:hover {
        text-decoration: underline;
    }

    .result-url {
        color: var(--secondary-color);
        font-size: 0.875rem;
        margin-bottom: 0.5rem;
    }

    .result-description {
        color: var(--text-dark);
        line-height: 1.5;
        margin-bottom: 0.75rem;
    }

    .result-meta {
        display: flex;
        gap: 1.5rem;
        font-size: 0.75rem;
        color: var(--text-light);
    }

    .result-meta-item {
        display: flex;
        align-items: center;
        gap: 0.25rem;
    }

    .rating {
        color: var(--warning-color);
    }

    /* Pagination */
    .pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 0.5rem;
        margin-top: 3rem;
    }

    .page-btn {
        padding: 0.5rem 0.75rem;
        border: 1px solid var(--border-color);
        border-radius: 4px;
        background-color: var(--bg-white);
        color: var(--text-dark);
        font-size: 0.875rem;
        transition: all 0.2s;
        min-width: 36px;
        text-align: center;
        cursor: pointer;
    }

    .page-btn:hover:not(.active):not(:disabled) {
        background-color: var(--bg-light);
        border-color: var(--text-light);
    }

    .page-btn.active {
        background-color: var(--text-dark);
        color: white;
        border-color: var(--text-dark);
    }

    .page-btn:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    /* Footer */
    .main-footer {
        background-color: var(--bg-light);
        border-top: 1px solid var(--border-color);
        margin-top: 4rem;
    }

    .footer-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 3rem 2rem 2rem;
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 2rem;
    }

    .footer-section h3 {
        font-size: 0.875rem;
        font-weight: 600;
        color: var(--text-dark);
        margin-bottom: 1rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .footer-section ul {
        list-style: none;
    }

    .footer-section ul li {
        margin-bottom: 0.75rem;
    }

    .footer-section ul li a {
        color: var(--text-light);
        font-size: 0.875rem;
        transition: color 0.2s;
        text-decoration: none;
    }

    .footer-section ul li a:hover {
        color: var(--primary-color);
    }

    .social-links {
        display: flex;
        gap: 1rem;
    }

    .social-link {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background-color: var(--bg-white);
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--text-light);
        border: 1px solid var(--border-color);
        transition: all 0.2s;
        text-decoration: none;
    }

    .social-link:hover {
        background-color: var(--primary-color);
        color: white;
        border-color: var(--primary-color);
    }

    .footer-bottom {
        text-align: center;
        padding: 1.5rem 2rem;
        border-top: 1px solid var(--border-color);
        color: var(--text-light);
        font-size: 0.875rem;
    }

    @media (max-width: 768px) {
        .header-container {
            padding: 1rem;
        }

        .main-nav {
            gap: 1rem;
        }

        .nav-link {
            padding: 0.5rem;
            font-size: 0.8rem;
        }

        .search-title {
            font-size: 2rem;
        }

        .search-icon-large {
            font-size: 3rem;
        }

        .search-box {
            padding: 0.5rem 0.75rem;
        }

        .search-options {
            flex-direction: column;
            align-items: center;
        }

        .option-btn {
            width: 200px;
            justify-content: center;
        }

        .filters-container {
            grid-template-columns: 1fr 1fr;
        }

        .result-card {
            padding: 1rem;
        }

        .result-icon {
            width: 40px;
            height: 40px;
            font-size: 1rem;
        }

        .result-title {
            font-size: 1rem;
        }

        .result-meta {
            flex-wrap: wrap;
            gap: 0.75rem;
        }

        .footer-container {
            grid-template-columns: 1fr 1fr;
            padding: 2rem 1rem;
        }
    }

    @media (max-width: 480px) {
        .filters-container {
            grid-template-columns: 1fr;
        }

        .footer-container {
            grid-template-columns: 1fr;
            text-align: center;
        }

        .social-links {
            justify-content: center;
        }
    }
    """
end

"""
    get_css()

共通のCSSスタイルを返す
"""
function get_css()
    return """
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        padding: 20px;
    }

    .container {
        max-width: 900px;
        margin: 0 auto;
    }

    .main-header {
        text-align: center;
        color: white;
        margin-bottom: 30px;
    }

    .main-header h1 {
        font-size: 3em;
        margin-bottom: 10px;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
    }

    .subtitle {
        font-size: 1.2em;
        opacity: 0.9;
    }

    .search-header {
        background: white;
        border-radius: 10px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }

    .search-header h1 {
        font-size: 1.8em;
        margin-bottom: 15px;
    }

    .search-header h1 a {
        color: #667eea;
        text-decoration: none;
    }

    .stats-card {
        background: rgba(255,255,255,0.95);
        border-radius: 10px;
        padding: 20px;
        margin-bottom: 30px;
        text-align: center;
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }

    .stat-item {
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    .stat-label {
        font-size: 1.1em;
        color: #666;
        margin-bottom: 5px;
    }

    .stat-value {
        font-size: 2.5em;
        font-weight: bold;
        color: #667eea;
    }

    .search-form {
        margin-bottom: 30px;
    }

    .search-form.inline {
        margin-bottom: 0;
    }

    .search-box {
        background: white;
        border-radius: 50px;
        padding: 10px 20px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        display: flex;
        align-items: center;
    }

    .search-input {
        flex: 1;
        border: none;
        outline: none;
        font-size: 18px;
        padding: 10px;
    }

    .search-button {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        border-radius: 50px;
        padding: 12px 30px;
        font-size: 16px;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    .search-button:hover {
        transform: scale(1.05);
        box-shadow: 0 5px 15px rgba(0,0,0,0.3);
    }

    .info-section {
        background: rgba(255,255,255,0.95);
        border-radius: 10px;
        padding: 25px;
        margin-bottom: 30px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }

    .info-section h2 {
        color: #333;
        margin-bottom: 15px;
        font-size: 1.4em;
    }

    .category-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 15px;
    }

    .category-item {
        background: #f8f9fa;
        padding: 12px 15px;
        border-radius: 8px;
        border-left: 4px solid #667eea;
        font-size: 0.95em;
    }

    .results-info {
        background: white;
        border-radius: 10px;
        padding: 15px 20px;
        margin-bottom: 20px;
        box-shadow: 0 3px 10px rgba(0,0,0,0.1);
    }

    .results-info p {
        color: #666;
        line-height: 1.6;
    }

    .index-info {
        font-size: 0.9em;
        margin-top: 5px;
    }

    .results-container {
        background: white;
        border-radius: 10px;
        padding: 20px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        margin-bottom: 30px;
    }

    .result-card {
        padding: 20px;
        border-bottom: 1px solid #eee;
        transition: all 0.3s ease;
    }

    .result-card:hover {
        background: #f8f9fa;
    }

    .result-card:last-child {
        border-bottom: none;
    }

    .result-title {
        margin-bottom: 8px;
        font-size: 1.3em;
    }

    .result-title a {
        color: #1a0dab;
        text-decoration: none;
    }

    .result-title a:hover {
        text-decoration: underline;
    }

    .badge {
        display: inline-block;
        padding: 3px 8px;
        border-radius: 4px;
        font-size: 0.75em;
        font-weight: 500;
        margin-left: 10px;
        vertical-align: middle;
    }

    .arxiv-badge {
        background: #b31b1b;
        color: white;
    }

    .result-url {
        color: #006621;
        font-size: 0.9em;
        margin-bottom: 8px;
    }

    .result-content {
        color: #545454;
        line-height: 1.6;
        margin-bottom: 10px;
    }

    .result-meta {
        font-size: 0.85em;
        color: #666;
        margin: 5px 0;
    }

    .result-score {
        margin-top: 10px;
        padding-top: 10px;
        border-top: 1px solid #f0f0f0;
    }

    .score-label {
        color: #888;
        font-size: 0.85em;
    }

    .score-value {
        color: #667eea;
        font-weight: bold;
        margin-left: 5px;
    }

    .no-results {
        text-align: center;
        padding: 40px;
        color: #666;
    }

    .no-results h3 {
        color: #333;
        margin-bottom: 15px;
    }

    .no-results ul {
        list-style: none;
        margin-top: 20px;
    }

    .no-results li {
        margin: 10px 0;
        padding-left: 20px;
        position: relative;
    }

    .no-results li::before {
        content: "•";
        color: #667eea;
        position: absolute;
        left: 0;
    }

    .main-footer {
        text-align: center;
        color: white;
        padding: 20px;
    }

    .main-footer a {
        color: white;
        text-decoration: none;
        font-weight: 500;
    }

    .main-footer a:hover {
        text-decoration: underline;
    }

    @media (max-width: 768px) {
        .main-header h1 {
            font-size: 2em;
        }

        .category-grid {
            grid-template-columns: 1fr;
        }

        .search-button span {
            display: none;
        }

        .search-button::after {
            content: "🔍";
        }
    }
    """
end

"""
    render_advanced_search()

詳細検索ページのHTMLを生成
"""
function render_advanced_search()
    return """
    <!DOCTYPE html>
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>詳細検索 - Julia検索エンジン</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    </head>
    <body>
        <!-- Header Navigation -->
        <header class="main-header">
            <div class="header-container">
                <div class="logo">
                    <i class="fas fa-search"></i>
                    <a href="/" style="color: inherit; text-decoration: none;"><span>Julia検索エンジン</span></a>
                </div>
                <nav class="main-nav">
                    <a href="/" class="nav-link">ホーム</a>
                    <a href="/advanced" class="nav-link active">詳細検索</a>
                    <a href="/images" class="nav-link">画像</a>
                    <a href="/news" class="nav-link">ニュース</a>
                    <a href="/settings" class="settings-btn"><i class="fas fa-cog"></i></a>
                    <a href="/user" class="user-avatar">
                        <i class="fas fa-user-circle"></i>
                    </a>
                </nav>
            </div>
        </header>

        <!-- Main Content -->
        <main class="main-content">
            <section class="advanced-search-section">
                <h1>詳細検索</h1>
                <form action="/search" method="get" class="advanced-form">
                    <div class="form-group">
                        <label for="keywords">キーワード</label>
                        <input type="text" id="keywords" name="q" placeholder="検索したいキーワードを入力">
                    </div>

                    <div class="form-group">
                        <label for="author">著者</label>
                        <input type="text" id="author" name="author" placeholder="著者名を入力">
                    </div>

                    <div class="form-group">
                        <label for="category">カテゴリ</label>
                        <select id="category" name="category">
                            <option value="">すべてのカテゴリ</option>
                            <option value="cs.AI">人工知能 (cs.AI)</option>
                            <option value="cs.LG">機械学習 (cs.LG)</option>
                            <option value="cs.CL">計算言語学 (cs.CL)</option>
                            <option value="cs.CV">コンピュータビジョン (cs.CV)</option>
                            <option value="cs.IR">情報検索 (cs.IR)</option>
                            <option value="stat.ML">統計機械学習 (stat.ML)</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="year">年</label>
                        <select id="year" name="year">
                            <option value="">すべての年</option>
                            <option value="2025">2025年</option>
                            <option value="2024">2024年</option>
                            <option value="2023">2023年</option>
                            <option value="2022">2022年</option>
                        </select>
                    </div>

                    <button type="submit" class="search-button">
                        <i class="fas fa-search"></i> 詳細検索
                    </button>
                </form>
            </section>
        </main>

        <style>
            $(get_google_style_css())

            .advanced-search-section {
                max-width: 600px;
                margin: 4rem auto;
                padding: 2rem;
            }

            .advanced-search-section h1 {
                font-size: 2rem;
                margin-bottom: 2rem;
                color: var(--text-dark);
            }

            .advanced-form {
                display: flex;
                flex-direction: column;
                gap: 1.5rem;
            }

            .form-group {
                display: flex;
                flex-direction: column;
                gap: 0.5rem;
            }

            .form-group label {
                font-weight: 500;
                color: var(--text-dark);
            }

            .form-group input, .form-group select {
                padding: 0.75rem;
                border: 1px solid var(--border-color);
                border-radius: 4px;
                font-size: 1rem;
            }

            .nav-link.active {
                background-color: var(--bg-light);
                border-radius: 4px;
            }
        </style>
    </body>
    </html>
    """
end

"""
    render_image_search()

画像検索ページのHTMLを生成
"""
function render_image_search()
    return """
    <!DOCTYPE html>
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>画像検索 - Julia検索エンジン</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    </head>
    <body>
        <!-- Header Navigation -->
        <header class="main-header">
            <div class="header-container">
                <div class="logo">
                    <i class="fas fa-search"></i>
                    <a href="/" style="color: inherit; text-decoration: none;"><span>Julia検索エンジン</span></a>
                </div>
                <nav class="main-nav">
                    <a href="/" class="nav-link">ホーム</a>
                    <a href="/advanced" class="nav-link">詳細検索</a>
                    <a href="/images" class="nav-link active">画像</a>
                    <a href="/news" class="nav-link">ニュース</a>
                    <a href="/settings" class="settings-btn"><i class="fas fa-cog"></i></a>
                    <a href="/user" class="user-avatar">
                        <i class="fas fa-user-circle"></i>
                    </a>
                </nav>
            </div>
        </header>

        <!-- Main Content -->
        <main class="main-content">
            <section class="coming-soon-section">
                <div class="coming-soon-content">
                    <i class="fas fa-image coming-soon-icon"></i>
                    <h1>画像検索</h1>
                    <p>論文内の図表や画像を検索する機能は現在開発中です。</p>
                    <p>近日公開予定です。</p>
                    <a href="/" class="back-button">ホームに戻る</a>
                </div>
            </section>
        </main>

        <style>
            $(get_google_style_css())

            .coming-soon-section {
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 60vh;
            }

            .coming-soon-content {
                text-align: center;
                max-width: 500px;
                padding: 2rem;
            }

            .coming-soon-icon {
                font-size: 4rem;
                color: var(--text-light);
                margin-bottom: 1.5rem;
            }

            .coming-soon-content h1 {
                font-size: 2rem;
                margin-bottom: 1rem;
                color: var(--text-dark);
            }

            .coming-soon-content p {
                color: var(--text-light);
                margin-bottom: 0.5rem;
                line-height: 1.6;
            }

            .back-button {
                display: inline-block;
                margin-top: 2rem;
                padding: 0.75rem 1.5rem;
                background: var(--primary-color);
                color: white;
                text-decoration: none;
                border-radius: 4px;
                transition: background-color 0.2s;
            }

            .back-button:hover {
                background: #3367d6;
            }

            .nav-link.active {
                background-color: var(--bg-light);
                border-radius: 4px;
            }
        </style>
    </body>
    </html>
    """
end

"""
    render_news_page()

ニュースページのHTMLを生成
"""
function render_news_page()
    return """
    <!DOCTYPE html>
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ニュース - Julia検索エンジン</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    </head>
    <body>
        <!-- Header Navigation -->
        <header class="main-header">
            <div class="header-container">
                <div class="logo">
                    <i class="fas fa-search"></i>
                    <a href="/" style="color: inherit; text-decoration: none;"><span>Julia検索エンジン</span></a>
                </div>
                <nav class="main-nav">
                    <a href="/" class="nav-link">ホーム</a>
                    <a href="/advanced" class="nav-link">詳細検索</a>
                    <a href="/images" class="nav-link">画像</a>
                    <a href="/news" class="nav-link active">ニュース</a>
                    <a href="/settings" class="settings-btn"><i class="fas fa-cog"></i></a>
                    <a href="/user" class="user-avatar">
                        <i class="fas fa-user-circle"></i>
                    </a>
                </nav>
            </div>
        </header>

        <!-- Main Content -->
        <main class="main-content">
            <section class="news-section">
                <h1>最新研究ニュース</h1>
                <div class="news-grid">
                    <article class="news-item">
                        <div class="news-icon">
                            <i class="fas fa-robot"></i>
                        </div>
                        <div class="news-content">
                            <h3>人工知能分野の最新動向</h3>
                            <p>AIの最新研究論文が続々と公開されています。今週は機械学習の新しいアプローチに関する論文が注目を集めています。</p>
                            <span class="news-date">2025年1月15日</span>
                        </div>
                    </article>

                    <article class="news-item">
                        <div class="news-icon">
                            <i class="fas fa-eye"></i>
                        </div>
                        <div class="news-content">
                            <h3>コンピュータビジョンの進歩</h3>
                            <p>深層学習を用いた画像認識技術に関する研究が急速に発展しています。新しい手法により認識精度が大幅に向上しました。</p>
                            <span class="news-date">2025年1月12日</span>
                        </div>
                    </article>

                    <article class="news-item">
                        <div class="news-icon">
                            <i class="fas fa-comments"></i>
                        </div>
                        <div class="news-content">
                            <h3>自然言語処理の新展開</h3>
                            <p>大規模言語モデルの研究が新たな段階に入りました。より効率的で高性能なモデルの開発が進んでいます。</p>
                            <span class="news-date">2025年1月10日</span>
                        </div>
                    </article>
                </div>
            </section>
        </main>

        <style>
            $(get_google_style_css())

            .news-section {
                max-width: 800px;
                margin: 2rem auto;
                padding: 2rem;
            }

            .news-section h1 {
                font-size: 2rem;
                margin-bottom: 2rem;
                color: var(--text-dark);
            }

            .news-grid {
                display: flex;
                flex-direction: column;
                gap: 1.5rem;
            }

            .news-item {
                display: flex;
                gap: 1rem;
                padding: 1.5rem;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                border: 1px solid var(--border-color);
            }

            .news-icon {
                flex-shrink: 0;
                width: 48px;
                height: 48px;
                background: var(--primary-color);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 1.25rem;
            }

            .news-content h3 {
                margin-bottom: 0.5rem;
                color: var(--text-dark);
                font-size: 1.125rem;
            }

            .news-content p {
                color: var(--text-light);
                line-height: 1.6;
                margin-bottom: 0.75rem;
            }

            .news-date {
                font-size: 0.875rem;
                color: var(--text-light);
            }

            .nav-link.active {
                background-color: var(--bg-light);
                border-radius: 4px;
            }
        </style>
    </body>
    </html>
    """
end

"""
    render_settings_page()

設定ページのHTMLを生成
"""
function render_settings_page()
    return """
    <!DOCTYPE html>
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>設定 - Julia検索エンジン</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    </head>
    <body>
        <!-- Header Navigation -->
        <header class="main-header">
            <div class="header-container">
                <div class="logo">
                    <i class="fas fa-search"></i>
                    <a href="/" style="color: inherit; text-decoration: none;"><span>Julia検索エンジン</span></a>
                </div>
                <nav class="main-nav">
                    <a href="/" class="nav-link">ホーム</a>
                    <a href="/advanced" class="nav-link">詳細検索</a>
                    <a href="/images" class="nav-link">画像</a>
                    <a href="/news" class="nav-link">ニュース</a>
                    <a href="/settings" class="settings-btn active"><i class="fas fa-cog"></i></a>
                    <a href="/user" class="user-avatar">
                        <i class="fas fa-user-circle"></i>
                    </a>
                </nav>
            </div>
        </header>

        <!-- Main Content -->
        <main class="main-content">
            <section class="settings-section">
                <h1>設定</h1>
                <div class="settings-grid">
                    <div class="setting-item">
                        <div class="setting-icon">
                            <i class="fas fa-sync"></i>
                        </div>
                        <div class="setting-content">
                            <h3>インデックス更新</h3>
                            <p>最新の論文を取得してインデックスを更新します</p>
                            <button class="setting-button" onclick="updateIndex()">
                                <i class="fas fa-sync"></i> 今すぐ更新
                            </button>
                        </div>
                    </div>

                    <div class="setting-item">
                        <div class="setting-icon">
                            <i class="fas fa-chart-bar"></i>
                        </div>
                        <div class="setting-content">
                            <h3>システム状態</h3>
                            <p>検索エンジンの現在の状態を確認します</p>
                            <button class="setting-button" onclick="checkStatus()">
                                <i class="fas fa-chart-bar"></i> 状態確認
                            </button>
                        </div>
                    </div>

                    <div class="setting-item">
                        <div class="setting-icon">
                            <i class="fas fa-download"></i>
                        </div>
                        <div class="setting-content">
                            <h3>自動取得</h3>
                            <p>論文の自動取得機能を制御します</p>
                            <button class="setting-button" onclick="toggleFetcher()">
                                <i class="fas fa-pause"></i> 一時停止
                            </button>
                        </div>
                    </div>
                </div>

                <div id="status-info" class="status-info" style="display: none;">
                    <h3>システム状態</h3>
                    <div id="status-content"></div>
                </div>
            </section>
        </main>

        <style>
            $(get_google_style_css())

            .settings-section {
                max-width: 800px;
                margin: 2rem auto;
                padding: 2rem;
            }

            .settings-section h1 {
                font-size: 2rem;
                margin-bottom: 2rem;
                color: var(--text-dark);
            }

            .settings-grid {
                display: flex;
                flex-direction: column;
                gap: 1.5rem;
                margin-bottom: 2rem;
            }

            .setting-item {
                display: flex;
                gap: 1rem;
                padding: 1.5rem;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                border: 1px solid var(--border-color);
            }

            .setting-icon {
                flex-shrink: 0;
                width: 48px;
                height: 48px;
                background: var(--secondary-color);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 1.25rem;
            }

            .setting-content {
                flex: 1;
                display: flex;
                flex-direction: column;
                gap: 0.5rem;
            }

            .setting-content h3 {
                margin: 0;
                color: var(--text-dark);
                font-size: 1.125rem;
            }

            .setting-content p {
                margin: 0;
                color: var(--text-light);
                line-height: 1.6;
            }

            .setting-button {
                align-self: flex-start;
                margin-top: 0.75rem;
                padding: 0.5rem 1rem;
                background: var(--primary-color);
                color: white;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-size: 0.875rem;
                display: flex;
                align-items: center;
                gap: 0.5rem;
                transition: background-color 0.2s;
            }

            .setting-button:hover {
                background: #3367d6;
            }

            .status-info {
                background: white;
                border-radius: 8px;
                padding: 1.5rem;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                border: 1px solid var(--border-color);
            }

            .status-info h3 {
                margin-bottom: 1rem;
                color: var(--text-dark);
            }

            .settings-btn.active {
                background-color: var(--bg-light);
                border-radius: 50%;
            }
        </style>

        <script>
            async function updateIndex() {
                try {
                    const response = await fetch('/api/index/update', { method: 'POST' });
                    const result = await response.json();
                    if (result.success) {
                        alert('インデックスが正常に更新されました。追加された論文数: ' + result.papers_added);
                    } else {
                        alert('エラー: ' + result.error);
                    }
                } catch (error) {
                    alert('更新に失敗しました: ' + error.message);
                }
            }

            async function checkStatus() {
                try {
                    const response = await fetch('/api/status');
                    const status = await response.json();
                    const statusInfo = document.getElementById('status-info');
                    const statusContent = document.getElementById('status-content');

                    statusContent.innerHTML =
                        '<p><strong>ステータス:</strong> ' + status.status + '</p>' +
                        '<p><strong>インデックス済み論文数:</strong> ' + status.index.documents + '件</p>' +
                        '<p><strong>語彙数:</strong> ' + status.index.vocabulary + '語</p>' +
                        '<p><strong>フェッチャー:</strong> ' + (status.fetcher.running ? '動作中' : '停止中') + '</p>';
                    statusInfo.style.display = 'block';
                } catch (error) {
                    alert('状態確認に失敗しました: ' + error.message);
                }
            }

            async function toggleFetcher() {
                try {
                    const response = await fetch('/api/fetcher/stop', { method: 'POST' });
                    const result = await response.json();
                    if (result.success) {
                        alert('フェッチャーを停止しました');
                    } else {
                        alert('エラー: ' + result.error);
                    }
                } catch (error) {
                    alert('操作に失敗しました: ' + error.message);
                }
            }
        </script>
    </body>
    </html>
    """
end

"""
    render_user_page()

ユーザーページのHTMLを生成
"""
function render_user_page()
    index = SearchEngine.get_global_index()
    doc_count = length(index.documents)

    # ユーザー統計を取得
    user_stats = UserManager.get_user_stats()
    search_history = UserManager.get_search_history()
    favorites = UserManager.get_favorites()

    return """
    <!DOCTYPE html>
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ユーザープロフィール - Julia検索エンジン</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    </head>
    <body>
        <!-- Header Navigation -->
        <header class="main-header">
            <div class="header-container">
                <div class="logo">
                    <i class="fas fa-search"></i>
                    <a href="/" style="color: inherit; text-decoration: none;"><span>Julia検索エンジン</span></a>
                </div>
                <nav class="main-nav">
                    <a href="/" class="nav-link">ホーム</a>
                    <a href="/advanced" class="nav-link">詳細検索</a>
                    <a href="/images" class="nav-link">画像</a>
                    <a href="/news" class="nav-link">ニュース</a>
                    <a href="/settings" class="settings-btn"><i class="fas fa-cog"></i></a>
                    <a href="/user" class="user-avatar active">
                        <i class="fas fa-user-circle"></i>
                    </a>
                </nav>
            </div>
        </header>

        <!-- Main Content -->
        <main class="main-content">
            <section class="user-profile-section">
                <div class="profile-header">
                    <div class="profile-avatar">
                        <i class="fas fa-user-circle"></i>
                    </div>
                    <div class="profile-info">
                        <h1>研究者プロフィール</h1>
                        <p class="profile-subtitle">Julia検索エンジンユーザー</p>
                    </div>
                </div>

                <div class="profile-content">
                    <div class="profile-section">
                        <h2><i class="fas fa-chart-line"></i> 検索統計</h2>
                        <div class="stats-grid">
                            <div class="stat-card">
                                <div class="stat-icon">
                                    <i class="fas fa-search"></i>
                                </div>
                                <div class="stat-info">
                                    <div class="stat-number">$(user_stats["search_count"])</div>
                                    <div class="stat-label">検索回数</div>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon">
                                    <i class="fas fa-bookmark"></i>
                                </div>
                                <div class="stat-info">
                                    <div class="stat-number">$(user_stats["favorites_count"])</div>
                                    <div class="stat-label">お気に入り論文</div>
                                </div>
                            </div>
                            <div class="stat-card">
                                <div class="stat-icon">
                                    <i class="fas fa-clock"></i>
                                </div>
                                <div class="stat-info">
                                    <div class="stat-number">$(user_stats["last_access"])</div>
                                    <div class="stat-label">最終アクセス</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="profile-section">
                        <h2><i class="fas fa-history"></i> 検索履歴</h2>
                        <div class="search-history">
                            $(isempty(search_history) ?
                                """<div class="history-item">
                                    <div class="history-icon">
                                        <i class="fas fa-info-circle"></i>
                                    </div>
                                    <div class="history-content">
                                        <div class="history-query">検索履歴はまだありません</div>
                                        <div class="history-time">検索を開始してください</div>
                                    </div>
                                </div>""" :
                                join(["""<div class="history-item">
                                    <div class="history-icon">
                                        <i class="fas fa-search"></i>
                                    </div>
                                    <div class="history-content">
                                        <div class="history-query">$(entry["query"])</div>
                                        <div class="history-time">$(entry["formatted_time"]) - $(entry["results_count"])件の結果</div>
                                    </div>
                                </div>""" for entry in search_history], "\n")
                            )
                        </div>
                    </div>

                    <div class="profile-section">
                        <h2><i class="fas fa-star"></i> お気に入り論文</h2>
                        <div class="favorite-papers">
                            $(isempty(favorites) ?
                                """<div class="favorite-item">
                                    <div class="favorite-icon">
                                        <i class="fas fa-info-circle"></i>
                                    </div>
                                    <div class="favorite-content">
                                        <div class="favorite-title">お気に入り論文はまだありません</div>
                                        <div class="favorite-subtitle">検索結果から論文をお気に入りに追加してください</div>
                                    </div>
                                </div>""" :
                                """<div class="favorite-item">
                                    <div class="favorite-icon">
                                        <i class="fas fa-star"></i>
                                    </div>
                                    <div class="favorite-content">
                                        <div class="favorite-title">$(length(favorites))件のお気に入り論文</div>
                                        <div class="favorite-subtitle">詳細なお気に入り管理機能は近日公開予定</div>
                                    </div>
                                </div>"""
                            )
                        </div>
                    </div>

                    <div class="profile-section">
                        <h2><i class="fas fa-cog"></i> アカウント設定</h2>
                        <div class="account-settings">
                            <div class="setting-item">
                                <div class="setting-label">表示言語</div>
                                <select class="setting-select">
                                    <option value="ja" selected>日本語</option>
                                    <option value="en">English</option>
                                </select>
                            </div>
                            <div class="setting-item">
                                <div class="setting-label">テーマ</div>
                                <select class="setting-select">
                                    <option value="light" selected>ライト</option>
                                    <option value="dark">ダーク</option>
                                    <option value="auto">自動</option>
                                </select>
                            </div>
                            <div class="setting-item">
                                <div class="setting-label">検索結果表示数</div>
                                <select class="setting-select">
                                    <option value="10">10件</option>
                                    <option value="20" selected>20件</option>
                                    <option value="50">50件</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="profile-section">
                        <h2><i class="fas fa-info-circle"></i> システム情報</h2>
                        <div class="system-info">
                            <div class="info-item">
                                <span class="info-label">総論文数:</span>
                                <span class="info-value">$(doc_count)件</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">検索エンジン:</span>
                                <span class="info-value">Julia Search Engine v1.0</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">データソース:</span>
                                <span class="info-value">arXiv.org</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <!-- Footer -->
        <footer class="main-footer">
            <div class="footer-container">
                <div class="footer-section">
                    <h3>概要</h3>
                    <ul>
                        <li><a href="#">検索の仕組み</a></li>
                        <li><a href="#">プロジェクトについて</a></li>
                        <li><a href="#">開発情報</a></li>
                    </ul>
                </div>

                <div class="footer-section">
                    <h3>サポート</h3>
                    <ul>
                        <li><a href="#">ヘルプセンター</a></li>
                        <li><a href="#">お問い合わせ</a></li>
                        <li><a href="#">フィードバック</a></li>
                    </ul>
                </div>

                <div class="footer-section">
                    <h3>法的事項</h3>
                    <ul>
                        <li><a href="#">プライバシーポリシー</a></li>
                        <li><a href="#">利用規約</a></li>
                        <li><a href="#">クッキーポリシー</a></li>
                    </ul>
                </div>

                <div class="footer-section">
                    <h3>つながり</h3>
                    <div class="social-links">
                        <a href="#" class="social-link"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-facebook"></i></a>
                        <a href="#" class="social-link"><i class="fab fa-linkedin"></i></a>
                    </div>
                </div>
            </div>

            <div class="footer-bottom">
                <p>&copy; 2025 Julia検索エンジン. すべての権利を保有.</p>
            </div>
        </footer>

        <style>
            $(get_google_style_css())

            .user-profile-section {
                max-width: 900px;
                margin: 2rem auto;
                padding: 2rem;
            }

            .profile-header {
                display: flex;
                align-items: center;
                gap: 1.5rem;
                margin-bottom: 3rem;
                padding: 2rem;
                background: white;
                border-radius: 12px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                border: 1px solid var(--border-color);
            }

            .profile-avatar {
                flex-shrink: 0;
                width: 80px;
                height: 80px;
                background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 2.5rem;
            }

            .profile-info h1 {
                margin: 0 0 0.5rem 0;
                color: var(--text-dark);
                font-size: 1.75rem;
            }

            .profile-subtitle {
                margin: 0;
                color: var(--text-light);
                font-size: 1rem;
            }

            .profile-content {
                display: flex;
                flex-direction: column;
                gap: 2rem;
            }

            .profile-section {
                background: white;
                border-radius: 8px;
                padding: 1.5rem;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                border: 1px solid var(--border-color);
            }

            .profile-section h2 {
                margin: 0 0 1.5rem 0;
                color: var(--text-dark);
                font-size: 1.25rem;
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }

            .profile-section h2 i {
                color: var(--primary-color);
            }

            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 1rem;
            }

            .stat-card {
                display: flex;
                align-items: center;
                gap: 1rem;
                padding: 1rem;
                background: var(--bg-light);
                border-radius: 8px;
            }

            .stat-icon {
                width: 40px;
                height: 40px;
                background: var(--primary-color);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 1rem;
            }

            .stat-number {
                font-size: 1.5rem;
                font-weight: 600;
                color: var(--text-dark);
            }

            .stat-label {
                font-size: 0.875rem;
                color: var(--text-light);
            }

            .search-history, .favorite-papers {
                display: flex;
                flex-direction: column;
                gap: 1rem;
            }

            .history-item, .favorite-item {
                display: flex;
                align-items: center;
                gap: 1rem;
                padding: 1rem;
                background: var(--bg-light);
                border-radius: 8px;
            }

            .history-icon, .favorite-icon {
                width: 32px;
                height: 32px;
                background: var(--secondary-color);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 0.875rem;
            }

            .history-query, .favorite-title {
                font-weight: 500;
                color: var(--text-dark);
            }

            .history-time, .favorite-subtitle {
                font-size: 0.875rem;
                color: var(--text-light);
            }

            .account-settings {
                display: flex;
                flex-direction: column;
                gap: 1rem;
            }

            .setting-item {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 0.75rem 0;
                border-bottom: 1px solid var(--border-color);
            }

            .setting-item:last-child {
                border-bottom: none;
            }

            .setting-label {
                font-weight: 500;
                color: var(--text-dark);
            }

            .setting-select {
                padding: 0.5rem;
                border: 1px solid var(--border-color);
                border-radius: 4px;
                background: white;
                color: var(--text-dark);
                font-size: 0.875rem;
            }

            .system-info {
                display: flex;
                flex-direction: column;
                gap: 0.75rem;
            }

            .info-item {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 0.5rem 0;
            }

            .info-label {
                color: var(--text-light);
                font-size: 0.875rem;
            }

            .info-value {
                color: var(--text-dark);
                font-weight: 500;
                font-size: 0.875rem;
            }

            .user-avatar.active {
                background-color: var(--bg-light);
            }

            @media (max-width: 768px) {
                .profile-header {
                    flex-direction: column;
                    text-align: center;
                    gap: 1rem;
                }

                .stats-grid {
                    grid-template-columns: 1fr;
                }

                .setting-item {
                    flex-direction: column;
                    align-items: flex-start;
                    gap: 0.5rem;
                }
            }
        </style>
    </body>
    </html>
    """
end

end # module