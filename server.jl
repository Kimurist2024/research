# ============================================================================
# メインサーバーモジュール
# ============================================================================

include("paper_manager.jl")
include("web_interface.jl")

using HTTP

"""
ウェブサーバーのHTTPリクエストを処理する
"""
function handle_request(req::HTTP.Request)
    if req.method == "GET"
        if req.target == "/"
            return HTTP.Response(200, html_template())
        elseif startswith(req.target, "/search")
            uri = HTTP.URI(req.target)
            params = HTTP.queryparams(uri)
            query = get(params, "q", "")

            if !isempty(query)
                results = search(global_index, query, 20)
                return HTTP.Response(200, html_template(results, query))
            else
                return HTTP.Response(200, html_template())
            end
        end
    end

    return HTTP.Response(404, "Not Found")
end

"""
オプションのバックグラウンド論文取得と共にウェブサーバーを開始する
"""
function start_server(port=0, fetch_papers=true, fetch_interval=1800)
    initialize_sample_data()

    if fetch_papers
        categories = ["cs.AI", "cs.LG", "cs.CL", "cs.CV", "cs.IR", "stat.ML"]
        start_paper_fetching(fetch_interval, categories)
    end

    if port == 0
        port = rand(8000:9999)
    end

    server = HTTP.serve!(handle_request, "0.0.0.0", port)
    println("🚀 サーバーが起動したらしい。謎ですね: http://localhost:$port")
    if fetch_papers
        println(" 論文の自動取得成功（間隔: $(fetch_interval)秒）")
    end

    try
        wait(server)
    catch e
        if e isa InterruptException
            println("\nサーバーを停止。死ぬまで動くな")
            if fetch_papers
                stop_paper_fetching()
            end
            close(server)
        else
            rethrow(e)
        end
    end
end

# ============================================================================
# メインエントリーポイント
# ============================================================================

if abspath(PROGRAM_FILE) == @__FILE__
    start_server()
end