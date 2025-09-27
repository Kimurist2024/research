module Config

using JSON3
using Logging

export AppConfig, ServerConfig, FetcherConfig, load_config, save_config

"""
    ServerConfig

サーバー設定
"""
struct ServerConfig
    port::Int
    host::String
end

"""
    FetcherConfig

論文取得設定
"""
struct FetcherConfig
    enabled::Bool
    interval::Int
    categories::Vector{String}
    max_results::Int
end

"""
    AppConfig

アプリケーション設定
"""
struct AppConfig
    server::ServerConfig
    fetcher::FetcherConfig
end

"""
    load_config(path::String)

設定ファイルを読み込む

# Arguments
- `path::String`: 設定ファイルのパス

# Returns
- `AppConfig`: アプリケーション設定
"""
function load_config(path::String="config/config.json")
    # デフォルト設定
    default_config = AppConfig(
        ServerConfig(8080, "0.0.0.0"),
        FetcherConfig(
            true,
            1800,
            ["cs.AI", "cs.LG", "cs.CL", "cs.CV"],
            200
        )
    )

    # ファイルが存在しない場合はデフォルトを作成
    if !isfile(path)
        @info "Config file not found, creating default config" path=path
        save_config(default_config, path)
        return default_config
    end

    try
        # 設定ファイル読み込み
        config_json = read(path, String)
        config_dict = JSON3.read(config_json, Dict{String, Any})

        # サーバー設定
        server_dict = get(config_dict, "server", Dict())
        server = ServerConfig(
            get(server_dict, "port", 8080),
            get(server_dict, "host", "0.0.0.0")
        )

        # フェッチャー設定
        fetcher_dict = get(config_dict, "fetcher", Dict())
        fetcher = FetcherConfig(
            get(fetcher_dict, "enabled", true),
            get(fetcher_dict, "interval", 1800),
            Vector{String}(get(fetcher_dict, "categories", ["cs.AI", "cs.LG", "cs.CL", "cs.CV"])),
            get(fetcher_dict, "max_results", 200)
        )

        config = AppConfig(server, fetcher)
        @info "Config loaded successfully" path=path
        return config

    catch e
        @error "Failed to load config, using defaults" path=path exception=e
        return default_config
    end
end

"""
    save_config(config::AppConfig, path::String)

設定をファイルに保存

# Arguments
- `config::AppConfig`: 保存する設定
- `path::String`: 保存先パス
"""
function save_config(config::AppConfig, path::String="config/config.json")
    # ディレクトリ作成
    dir = dirname(path)
    if !isdir(dir)
        mkpath(dir)
    end

    # 設定を辞書に変換
    config_dict = Dict(
        "server" => Dict(
            "port" => config.server.port,
            "host" => config.server.host
        ),
        "fetcher" => Dict(
            "enabled" => config.fetcher.enabled,
            "interval" => config.fetcher.interval,
            "categories" => config.fetcher.categories,
            "max_results" => config.fetcher.max_results
        )
    )

    # JSON形式で保存
    json_str = JSON3.pretty(config_dict, indent=2)
    write(path, json_str)

    @info "Config saved" path=path
end

end # module