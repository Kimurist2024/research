# ============================================================================
# ウェブインターフェースモジュール
# ============================================================================

"""
ウェブインターフェース用のHTMLテンプレートを生成する
"""
function html_template(results="", query="")
    results_html = ""
    if !isempty(results)
        for result in results
            is_arxiv = occursin("arxiv.org", result.url)
            badge = is_arxiv ? "<span class='arxiv-badge'>arXiv</span>" : ""

            content_preview = if length(result.content) > 300
                result.content[1:300] * "..."
            else
                result.content
            end

            results_html *= """
            <div class="result">
                <h3><a href="$(result.url)">$(result.title)</a>$badge</h3>
                <p class="url">$(result.url)</p>
                <p class="content">$(content_preview)</p>
            </div>
            """
        end
    end

    return """
    <!DOCTYPE html>
    <html lang="ja">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Julia検索エンジン</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                padding: 20px;
            }

            .container {
                max-width: 800px;
                margin: 0 auto;
            }

            h1 {
                text-align: center;
                color: white;
                margin-bottom: 30px;
                font-size: 2.5em;
                text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
            }

            .search-box {
                background: white;
                border-radius: 50px;
                padding: 10px 20px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
                display: flex;
                align-items: center;
                margin-bottom: 30px;
            }

            input[type="text"] {
                flex: 1;
                border: none;
                outline: none;
                font-size: 18px;
                padding: 10px;
            }

            button {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                border-radius: 50px;
                padding: 12px 30px;
                font-size: 16px;
                cursor: pointer;
                transition: all 0.3s ease;
            }

            button:hover {
                transform: scale(1.05);
                box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            }

            .results {
                background: white;
                border-radius: 20px;
                padding: 20px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            }

            .result {
                padding: 20px;
                border-bottom: 1px solid #eee;
                transition: all 0.3s ease;
            }

            .result:hover {
                background: #f8f9fa;
            }

            .result:last-child {
                border-bottom: none;
            }

            .result h3 {
                margin-bottom: 5px;
            }

            .result h3 a {
                color: #1a0dab;
                text-decoration: none;
                font-size: 1.2em;
            }

            .result h3 a:hover {
                text-decoration: underline;
            }

            .result .url {
                color: #006621;
                font-size: 14px;
                margin-bottom: 5px;
            }

            .result .content {
                color: #545454;
                line-height: 1.5;
            }

            .arxiv-badge {
                display: inline-block;
                background: #b31b1b;
                color: white;
                padding: 2px 8px;
                border-radius: 3px;
                font-size: 12px;
                margin-left: 10px;
            }

            .paper-info {
                margin-top: 8px;
                font-size: 13px;
                color: #666;
            }

            .stats {
                background: rgba(255,255,255,0.9);
                border-radius: 10px;
                padding: 15px;
                margin-bottom: 20px;
                text-align: center;
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            }

            .stats span {
                color: #667eea;
                font-weight: bold;
                font-size: 1.2em;
            }

            .no-results {
                text-align: center;
                color: #666;
                padding: 40px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🔍 Julia検索エンジン</h1>
            <div class="stats">
                インデックス済み文書: <span>$(length(global_index.documents))</span> 件
            </div>
            <form action="/search" method="get">
                <div class="search-box">
                    <input type="text" name="q" placeholder="検索キーワードを入力（論文タイトル、キーワード等）..." value="$(query)" autofocus>
                    <button type="submit">検索</button>
                </div>
            </form>

            $(if !isempty(results_html)
                "<div class='results'>$results_html</div>"
            elseif !isempty(query)
                "<div class='results'><div class='no-results'>「$(query)」に一致する結果は見つかりませんでした。</div></div>"
            else
                ""
            end)
        </div>
    </body>
    </html>
    """
end