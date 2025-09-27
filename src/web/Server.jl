module Server

using HTTP
using Logging
using Sockets
using ..PaperFetcher
using ..RequestHandler

export start_server, stop_server

# サーバーインスタンス
global server_instance = nothing

"""
    find_available_port(start_port::Int=8080)

利用可能なポートを見つける
"""
function find_available_port(start_port::Int=8080)
    for port in start_port:(start_port + 100)
        try
            # ポートが利用可能かテスト
            server = listen(IPv4("0.0.0.0"), port)
            close(server)
            return port
        catch e
            continue
        end
    end
    error("No available port found in range $(start_port) to $(start_port + 100)")
end

"""
    start_server(; port::Int=8080, fetch_papers::Bool=true, fetch_interval::Int=1800, categories::Vector{String}=["cs.AI"])

Webサーバーを起動

# Arguments
- `port::Int`: 希望ポート番号（利用不可の場合は自動で次のポートを使用）
- `fetch_papers::Bool`: 論文自動取得を有効化
- `fetch_interval::Int`: 取得間隔（秒）
- `categories::Vector{String}`: 取得カテゴリ
"""
function start_server(;
    port::Int=8080,
    fetch_papers::Bool=true,
    fetch_interval::Int=1800,
    categories::Vector{String}=["cs.AI", "cs.LG", "cs.CL", "cs.CV"]
)
    global server_instance

    # 利用可能なポートを見つける
    available_port = find_available_port(port)
    if available_port != port
        @warn "Port $port is not available, using port $available_port instead"
    end

    @info "Starting Julia Search Engine server..." port=available_port

    # 論文自動取得を開始
    if fetch_papers
        PaperFetcher.start_fetching(
            fetch_interval=fetch_interval,
            categories=categories
        )
    end

    # HTTPサーバー起動
    try
        server_instance = HTTP.serve!(RequestHandler.handle_request, "0.0.0.0", available_port)

        println("=" ^ 60)
        println("🚀 Julia Search Engine Server Started")
        println("=" ^ 60)
        println("📍 URL: http://localhost:$available_port")

        if fetch_papers
            println("📚 Auto-fetch: Enabled (interval: $(fetch_interval)s)")
            println("📂 Categories: $(join(categories, ", "))")
        else
            println("📚 Auto-fetch: Disabled")
        end

        println("=" ^ 60)
        println("Press Ctrl+C to stop the server")
        println("=" ^ 60)

        # サーバーを待機
        wait(server_instance)

    catch e
        if e isa InterruptException
            @info "Shutdown signal received"
            stop_server()
        else
            @error "Server error" exception=e
            rethrow(e)
        end
    end
end

"""
    stop_server()

サーバーを停止
"""
function stop_server()
    global server_instance

    @info "Stopping server..."

    # 論文フェッチャー停止
    PaperFetcher.stop_fetching()

    # HTTPサーバー停止
    if server_instance !== nothing
        try
            close(server_instance)
            @info "Server stopped successfully"
        catch e
            @error "Error stopping server" exception=e
        end
        server_instance = nothing
    end

    println("\n👋 Server stopped. Goodbye!")
end

end # module