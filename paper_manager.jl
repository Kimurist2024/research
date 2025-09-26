# ============================================================================
# 論文管理モジュール
# ============================================================================

include("search_engine.jl")
include("arxiv_client.jl")

using Dates

"""
グローバル検索インデックスインスタンス
"""
global_index = Index()

"""
サンプルデータで検索インデックスを初期化する
"""
function initialize_sample_data()
    println("Index initialized with $(length(global_index.documents)) documents")
end

"""
arXivからの新しい論文でグローバルインデックスを更新する
"""
function update_papers_from_arxiv(categories::Vector{String}=["cs.AI", "cs.LG", "cs.CL", "cs.CV"])
    println("[$(Dates.now())] 論文を取得中")

    total_added = 0

    for category in categories
        papers = fetch_papers("", category, 200, "submittedDate")

        for paper in papers
            content = """
            $(paper.abstract)

            Authors: $(join(paper.authors, ", "))
            Categories: $(join(paper.categories, ", "))
            Published: $(paper.published)
            """

            doc_id = add_document!(global_index, paper.title, content, paper.arxiv_url)
            total_added += 1
        end

        sleep(1)
    end

    calculate_idf!(global_index)
    calculate_tfidf_vectors!(global_index)

    println("[$(Dates.now())] $total_added 件の論文を追加.
    総文書数: $(length(global_index.documents))")
    return total_added
end

# ============================================================================
# バックグラウンド取得モジュール
# ============================================================================

"""
バックグラウンド論文取得の状態管理
"""
mutable struct FetcherState
    running::Bool
    last_fetch::DateTime
    fetch_interval::Int
    categories::Vector{String}
end

global fetcher_state = nothing

"""
定期的に論文を取得するバックグラウンドループ
"""
function fetch_loop()
    global fetcher_state
    global global_index

    while fetcher_state.running
        current_time = Dates.now()

        if current_time - fetcher_state.last_fetch >= Dates.Second(fetcher_state.fetch_interval)
            update_papers_from_arxiv(fetcher_state.categories)
            fetcher_state.last_fetch = current_time
        end

        sleep(60)
    end
end

"""
バックグラウンド論文取得サービスを開始する
"""
function start_paper_fetching(fetch_interval::Int=1800, categories::Vector{String}=["cs.AI", "cs.LG", "cs.CL", "cs.CV"])
    global fetcher_state = FetcherState(
        true,
        Dates.now(),
        fetch_interval,
        categories
    )

    update_papers_from_arxiv(categories)

    @async fetch_loop()

    println("[$(Dates.now())] 自動論文取得を開始（間隔: $(fetch_interval)秒）")
end

"""
バックグラウンド論文取得サービスを停止する
"""
function stop_paper_fetching()
    global fetcher_state
    if fetcher_state !== nothing
        fetcher_state.running = false
        println("[$(Dates.now())] 自動論文取得を停止")
    end
end