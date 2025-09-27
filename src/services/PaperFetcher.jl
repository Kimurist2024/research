module PaperFetcher

using Dates
using Logging
using ..ArxivClient
using ..SearchEngine

export FetcherState, start_fetching, stop_fetching, update_papers_from_arxiv, get_fetcher_status

"""
    FetcherState

論文取得サービスの状態管理
"""
mutable struct FetcherState
    running::Bool
    last_fetch::DateTime
    fetch_interval::Int
    categories::Vector{String}
    total_fetched::Int
    fetch_task::Union{Task, Nothing}
end

# グローバル状態
global fetcher_state = nothing

"""
    update_papers_from_arxiv(categories::Vector{String})

arXivから論文を取得してインデックスに追加

# Arguments
- `categories::Vector{String}`: 取得するカテゴリのリスト

# Returns
- `Int`: 追加された論文の総数
"""
function update_papers_from_arxiv(categories::Vector{String}=["cs.AI", "cs.LG", "cs.CL", "cs.CV"])
    @info "Fetching papers from arXiv..." categories=categories

    total_added = 0

    for category in categories
        try
            # カテゴリごとに論文取得
            papers = fetch_papers(
                category=category,
                max_results=200,
                sort_by="submittedDate"
            )

            # 各論文をインデックスに追加
            for paper in papers
                # メタデータ作成
                metadata = Dict{String, Any}(
                    "authors" => paper.authors,
                    "categories" => paper.categories,
                    "published" => paper.published,
                    "pdf_url" => paper.pdf_url,
                    "source" => "arxiv"
                )

                # 内容の構築
                content = """
                $(paper.abstract)

                Authors: $(join(paper.authors, ", "))
                Categories: $(join(paper.categories, ", "))
                Published: $(paper.published)
                """

                # インデックスに追加
                add_document_to_index!(
                    paper.title,
                    content,
                    paper.arxiv_url;
                    metadata=metadata
                )

                total_added += 1
            end

            # APIレート制限対応
            sleep(1)

        catch e
            @error "Failed to fetch papers for category" category=category exception=e
        end
    end

    # インデックスの再構築
    if total_added > 0
        build_index!()
    end

    @info "Papers added to index" total_added=total_added

    return total_added
end

"""
    fetch_loop()

定期的に論文を取得するループ
"""
function fetch_loop()
    global fetcher_state

    while fetcher_state !== nothing && fetcher_state.running
        current_time = Dates.now()

        # 指定間隔で取得実行
        if current_time - fetcher_state.last_fetch >= Dates.Second(fetcher_state.fetch_interval)
            try
                count = update_papers_from_arxiv(fetcher_state.categories)
                fetcher_state.total_fetched += count
                fetcher_state.last_fetch = current_time
                @info "Periodic fetch completed" papers_added=count total=fetcher_state.total_fetched
            catch e
                @error "Fetch loop error" exception=e
            end
        end

        # 1分ごとにチェック
        sleep(60)
    end
end

"""
    start_fetching(; fetch_interval::Int=1800, categories::Vector{String}=["cs.AI", "cs.LG", "cs.CL", "cs.CV"])

論文の定期取得を開始

# Arguments
- `fetch_interval::Int`: 取得間隔（秒）
- `categories::Vector{String}`: 取得するカテゴリ
"""
function start_fetching(;
    fetch_interval::Int=1800,
    categories::Vector{String}=["cs.AI", "cs.LG", "cs.CL", "cs.CV"]
)
    global fetcher_state

    # すでに実行中の場合
    if fetcher_state !== nothing && fetcher_state.running
        @warn "Fetcher is already running"
        return
    end

    # 状態初期化
    fetcher_state = FetcherState(
        true,
        Dates.now(),
        fetch_interval,
        categories,
        0,
        nothing
    )

    # 初回取得
    count = update_papers_from_arxiv(categories)
    fetcher_state.total_fetched = count

    # バックグラウンドタスク開始
    fetcher_state.fetch_task = @async fetch_loop()

    @info "Paper fetcher started" interval=fetch_interval categories=categories
end

"""
    stop_fetching()

論文の定期取得を停止
"""
function stop_fetching()
    global fetcher_state

    if fetcher_state === nothing
        @warn "Fetcher is not running"
        return
    end

    fetcher_state.running = false
    @info "Paper fetcher stopped" total_fetched=fetcher_state.total_fetched
end

"""
    get_fetcher_status()

フェッチャーの状態を取得

# Returns
- `Dict`: 状態情報
"""
function get_fetcher_status()
    global fetcher_state

    if fetcher_state === nothing
        return Dict(
            "running" => false,
            "message" => "Fetcher not initialized"
        )
    end

    return Dict(
        "running" => fetcher_state.running,
        "last_fetch" => string(fetcher_state.last_fetch),
        "fetch_interval" => fetcher_state.fetch_interval,
        "categories" => fetcher_state.categories,
        "total_fetched" => fetcher_state.total_fetched
    )
end

end # module