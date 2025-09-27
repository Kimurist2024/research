module RequestHandler

using HTTP
using JSON3
using Logging
using ..SearchEngine
using ..PaperFetcher
using ..HTMLTemplates
using ..UserManager

export handle_request

"""
    handle_request(req::HTTP.Request)

HTTPリクエストを処理

# Arguments
- `req::HTTP.Request`: HTTPリクエスト

# Returns
- `HTTP.Response`: HTTPレスポンス
"""
function handle_request(req::HTTP.Request)
    @info "Request received" method=req.method path=req.target

    # ルーティング
    if req.method == "GET"
        return handle_get_request(req)
    elseif req.method == "POST"
        return handle_post_request(req)
    else
        return HTTP.Response(405, "Method Not Allowed")
    end
end

"""
    handle_get_request(req::HTTP.Request)

GETリクエストの処理
"""
function handle_get_request(req::HTTP.Request)
    uri = HTTP.URI(req.target)
    path = uri.path

    # ルートパス
    if path == "/" || path == "/index"
        return serve_home_page()

    # 検索
    elseif path == "/search"
        params = HTTP.queryparams(uri)
        query = get(params, "q", "")
        return serve_search_results(query)

    # 詳細検索
    elseif path == "/advanced"
        return serve_advanced_search()

    # 画像検索
    elseif path == "/images"
        return serve_image_search()

    # ニュース
    elseif path == "/news"
        return serve_news_page()

    # 設定
    elseif path == "/settings"
        return serve_settings_page()

    # ユーザーページ
    elseif path == "/user" || path == "/profile"
        return serve_user_page()

    # API: ステータス
    elseif path == "/api/status"
        return serve_api_status()

    # API: 検索
    elseif startswith(path, "/api/search")
        params = HTTP.queryparams(uri)
        query = get(params, "q", "")
        top_k = parse(Int, get(params, "top_k", "10"))
        return serve_api_search(query, top_k)

    # 静的ファイル
    elseif startswith(path, "/static/")
        return serve_static_file(String(path[9:end]))

    else
        return HTTP.Response(404, "Not Found")
    end
end

"""
    handle_post_request(req::HTTP.Request)

POSTリクエストの処理
"""
function handle_post_request(req::HTTP.Request)
    uri = HTTP.URI(req.target)
    path = uri.path

    # API: インデックス更新
    if path == "/api/index/update"
        return update_index()

    # API: フェッチャー制御
    elseif path == "/api/fetcher/start"
        return start_fetcher()

    elseif path == "/api/fetcher/stop"
        return stop_fetcher()

    # API: お気に入り追加
    elseif path == "/api/favorites/add"
        return add_favorite_api(req)

    # API: お気に入り削除
    elseif path == "/api/favorites/remove"
        return remove_favorite_api(req)

    else
        return HTTP.Response(404, "Not Found")
    end
end

"""
    serve_home_page()

ホームページを表示
"""
function serve_home_page()
    html = HTMLTemplates.render_home()
    return HTTP.Response(200, ["Content-Type" => "text/html; charset=utf-8"], html)
end

"""
    serve_search_results(query::String)

検索結果ページを表示
"""
function serve_search_results(query::String)
    if isempty(query)
        return serve_home_page()
    end

    # 検索実行
    results = SearchEngine.search(query, top_k=20)

    # 検索履歴に追加
    UserManager.add_search_history(query, length(results))

    # HTML生成
    html = HTMLTemplates.render_search_results(query, results)
    return HTTP.Response(200, ["Content-Type" => "text/html; charset=utf-8"], html)
end

"""
    serve_advanced_search()

詳細検索ページを表示
"""
function serve_advanced_search()
    html = HTMLTemplates.render_advanced_search()
    return HTTP.Response(200, ["Content-Type" => "text/html; charset=utf-8"], html)
end

"""
    serve_image_search()

画像検索ページを表示
"""
function serve_image_search()
    html = HTMLTemplates.render_image_search()
    return HTTP.Response(200, ["Content-Type" => "text/html; charset=utf-8"], html)
end

"""
    serve_news_page()

ニュースページを表示
"""
function serve_news_page()
    html = HTMLTemplates.render_news_page()
    return HTTP.Response(200, ["Content-Type" => "text/html; charset=utf-8"], html)
end

"""
    serve_settings_page()

設定ページを表示
"""
function serve_settings_page()
    html = HTMLTemplates.render_settings_page()
    return HTTP.Response(200, ["Content-Type" => "text/html; charset=utf-8"], html)
end

"""
    serve_user_page()

ユーザーページを表示
"""
function serve_user_page()
    html = HTMLTemplates.render_user_page()
    return HTTP.Response(200, ["Content-Type" => "text/html; charset=utf-8"], html)
end

"""
    serve_api_status()

APIステータスをJSON形式で返す
"""
function serve_api_status()
    index = SearchEngine.get_global_index()
    fetcher_status = PaperFetcher.get_fetcher_status()

    status = Dict(
        "status" => "running",
        "index" => Dict(
            "documents" => length(index.documents),
            "vocabulary" => length(index.vocabulary)
        ),
        "fetcher" => fetcher_status
    )

    json = JSON3.write(status)
    return HTTP.Response(200, ["Content-Type" => "application/json"], json)
end

"""
    serve_api_search(query::String, top_k::Int)

API経由で検索を実行
"""
function serve_api_search(query::String, top_k::Int)
    if isempty(query)
        json = JSON3.write(Dict("error" => "Query is required"))
        return HTTP.Response(400, ["Content-Type" => "application/json"], json)
    end

    # 検索実行
    results = SearchEngine.search(query, top_k=top_k)

    # 結果をJSON形式に変換
    json_results = [
        Dict(
            "title" => r.title,
            "content" => length(r.content) > 500 ? r.content[1:500] * "..." : r.content,
            "url" => r.url,
            "score" => r.score,
            "metadata" => r.metadata
        )
        for r in results
    ]

    json = JSON3.write(Dict(
        "query" => query,
        "count" => length(results),
        "results" => json_results
    ))

    return HTTP.Response(200, ["Content-Type" => "application/json"], json)
end

"""
    update_index()

インデックスを更新
"""
function update_index()
    try
        categories = ["cs.AI", "cs.LG", "cs.CL", "cs.CV"]
        count = PaperFetcher.update_papers_from_arxiv(categories)

        json = JSON3.write(Dict(
            "success" => true,
            "papers_added" => count
        ))
        return HTTP.Response(200, ["Content-Type" => "application/json"], json)
    catch e
        json = JSON3.write(Dict(
            "success" => false,
            "error" => string(e)
        ))
        return HTTP.Response(500, ["Content-Type" => "application/json"], json)
    end
end

"""
    start_fetcher()

フェッチャーを開始
"""
function start_fetcher()
    try
        PaperFetcher.start_fetching()
        json = JSON3.write(Dict("success" => true))
        return HTTP.Response(200, ["Content-Type" => "application/json"], json)
    catch e
        json = JSON3.write(Dict(
            "success" => false,
            "error" => string(e)
        ))
        return HTTP.Response(500, ["Content-Type" => "application/json"], json)
    end
end

"""
    stop_fetcher()

フェッチャーを停止
"""
function stop_fetcher()
    try
        PaperFetcher.stop_fetching()
        json = JSON3.write(Dict("success" => true))
        return HTTP.Response(200, ["Content-Type" => "application/json"], json)
    catch e
        json = JSON3.write(Dict(
            "success" => false,
            "error" => string(e)
        ))
        return HTTP.Response(500, ["Content-Type" => "application/json"], json)
    end
end

"""
    serve_static_file(path::String)

静的ファイルを配信
"""
function serve_static_file(path::String)
    # セキュリティチェック
    if contains(path, "..") || contains(path, "~")
        return HTTP.Response(403, "Forbidden")
    end

    file_path = joinpath("static", path)

    if isfile(file_path)
        content = read(file_path, String)
        content_type = get_content_type(path)
        return HTTP.Response(200, ["Content-Type" => content_type], content)
    else
        return HTTP.Response(404, "Not Found")
    end
end

"""
    get_content_type(filename::String)

ファイル拡張子からContent-Typeを取得
"""
function get_content_type(filename::String)
    ext = lowercase(splitext(filename)[2])
    content_types = Dict(
        ".html" => "text/html",
        ".css" => "text/css",
        ".js" => "application/javascript",
        ".json" => "application/json",
        ".png" => "image/png",
        ".jpg" => "image/jpeg",
        ".svg" => "image/svg+xml"
    )
    return get(content_types, ext, "text/plain")
end

"""
    add_favorite_api(req::HTTP.Request)

お気に入りに追加するAPI
"""
function add_favorite_api(req::HTTP.Request)
    try
        body = String(req.body)
        data = JSON3.read(body)

        paper_url = get(data, "url", "")
        paper_title = get(data, "title", "")

        if isempty(paper_url) || isempty(paper_title)
            json = JSON3.write(Dict("success" => false, "error" => "URL and title are required"))
            return HTTP.Response(400, ["Content-Type" => "application/json"], json)
        end

        UserManager.add_favorite(paper_url, paper_title)

        json = JSON3.write(Dict("success" => true, "message" => "Added to favorites"))
        return HTTP.Response(200, ["Content-Type" => "application/json"], json)
    catch e
        json = JSON3.write(Dict("success" => false, "error" => string(e)))
        return HTTP.Response(500, ["Content-Type" => "application/json"], json)
    end
end

"""
    remove_favorite_api(req::HTTP.Request)

お気に入りから削除するAPI
"""
function remove_favorite_api(req::HTTP.Request)
    try
        body = String(req.body)
        data = JSON3.read(body)

        paper_url = get(data, "url", "")

        if isempty(paper_url)
            json = JSON3.write(Dict("success" => false, "error" => "URL is required"))
            return HTTP.Response(400, ["Content-Type" => "application/json"], json)
        end

        UserManager.remove_favorite(paper_url)

        json = JSON3.write(Dict("success" => true, "message" => "Removed from favorites"))
        return HTTP.Response(200, ["Content-Type" => "application/json"], json)
    catch e
        json = JSON3.write(Dict("success" => false, "error" => string(e)))
        return HTTP.Response(500, ["Content-Type" => "application/json"], json)
    end
end

end # module