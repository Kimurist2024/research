#!/usr/bin/env julia

using Logging

# モジュールインクルード
include("models/Document.jl")
include("models/Index.jl")
include("utils/TextProcessor.jl")
include("utils/Similarity.jl")
include("core/SearchEngine.jl")
include("services/ArxivClient.jl")
include("services/PaperFetcher.jl")
include("services/UserManager.jl")
include("web/HTMLTemplates.jl")
include("config/Config.jl")
include("web/RequestHandler.jl")
include("web/Server.jl")

using .Config
using .Server

"""
    start_application(; config_path::String="config/config.json")

メインアプリケーションのエントリーポイント
"""
function start_application(; config_path::String="config/config.json")
    @info "Julia Search Engine Starting..."

    # 設定読み込み
    config = load_config(config_path)

    # ロギング設定
    logger = ConsoleLogger(stderr, Logging.Info)
    global_logger(logger)

    # サーバー起動
    Server.start_server(
        port=config.server.port,
        fetch_papers=config.fetcher.enabled,
        fetch_interval=config.fetcher.interval,
        categories=config.fetcher.categories
    )
end

# スクリプトとして実行された場合
if abspath(PROGRAM_FILE) == @__FILE__
    start_application()
end