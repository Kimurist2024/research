using HTTP
using JSON3
using Sockets
using Dates
using LinearAlgebra

mutable struct Document
    id::String
    title::String
    content::String
    url::String
    tokens::Vector{String}
    tf::Dict{String, Float64}
    tfidf_vector::Vector{Float64}
end

mutable struct Index
    documents::Vector{Document}
    inverted_index::Dict{String, Set{String}}
    idf::Dict{String, Float64}
    vocabulary::Vector{String}
end

Index() = Index(Document[], Dict{String, Set{String}}(), Dict{String, Float64}(), String[])

function tokenize(text::String)
    lowercase_text = lowercase(text)
    words = split(lowercase_text, r"[\s\-_,;.!?()「」『』【】\[\]{}\"'`]+")
    return filter(w -> length(w) > 1, words)
end

function calculate_tf(tokens::Vector{<:AbstractString})
    tf = Dict{String, Float64}()
    total = length(tokens)

    for token in tokens
        tf[token] = get(tf, token, 0.0) + 1.0
    end

    for token in keys(tf)
        tf[token] = tf[token] / total
    end

    return tf
end

function add_document!(index::Index, title::String, content::String, url::String)
    doc_id = string(length(index.documents) + 1)

    full_text = title * " " * content
    tokens = tokenize(full_text)
    tf = calculate_tf(tokens)

    doc = Document(doc_id, title, content, url, tokens, tf, Float64[])
    push!(index.documents, doc)

    for token in Set(tokens)
        if !haskey(index.inverted_index, token)
            index.inverted_index[token] = Set{String}()
        end
        push!(index.inverted_index[token], doc_id)
    end

    return doc_id
end

function calculate_idf!(index::Index)
    n_docs = length(index.documents)

    for (term, doc_ids) in index.inverted_index
        df = length(doc_ids)
        index.idf[term] = log(n_docs / df)
    end

    index.vocabulary = sort(collect(keys(index.idf)))
end

function calculate_tfidf_vectors!(index::Index)
    vocab_size = length(index.vocabulary)
    term_to_idx = Dict(term => i for (i, term) in enumerate(index.vocabulary))

    for doc in index.documents
        doc.tfidf_vector = zeros(vocab_size)

        for (term, tf_value) in doc.tf
            if haskey(term_to_idx, term)
                idx = term_to_idx[term]
                idf_value = get(index.idf, term, 0.0)
                doc.tfidf_vector[idx] = tf_value * idf_value
            end
        end
    end
end

function cosine_similarity(vec1::Vector{Float64}, vec2::Vector{Float64})
    dot_product = dot(vec1, vec2)
    norm1 = norm(vec1)
    norm2 = norm(vec2)

    if norm1 == 0 || norm2 == 0
        return 0.0
    end

    return dot_product / (norm1 * norm2)
end

function search(index::Index, query::String, top_k::Int=10)
    query_tokens = tokenize(query)

    if isempty(query_tokens)
        return []
    end

    query_tf = calculate_tf(query_tokens)

    vocab_size = length(index.vocabulary)
    query_vector = zeros(vocab_size)
    term_to_idx = Dict(term => i for (i, term) in enumerate(index.vocabulary))

    for (term, tf_value) in query_tf
        if haskey(term_to_idx, term)
            idx = term_to_idx[term]
            idf_value = get(index.idf, term, 0.0)
            query_vector[idx] = tf_value * idf_value
        end
    end

    scores = []
    for doc in index.documents
        score = cosine_similarity(doc.tfidf_vector, query_vector)
        push!(scores, (doc, score))
    end

    sort!(scores, by=x->x[2], rev=true)

    results = []
    min_results = 10
    for i in 1:min(max(top_k, min_results), length(scores))
        if scores[i][2] > 0 || length(results) < min_results
            doc = scores[i][1]
            push!(results, (title=doc.title, content=doc.content, url=doc.url, score=scores[i][2]))
            if length(results) >= max(top_k, min_results)
                break
            end
        end
    end

    return results
end

struct ArxivPaper
    title::String
    abstract::String
    authors::Vector{String}
    published::String
    categories::Vector{String}
    arxiv_url::String
end

function parse_arxiv_response(xml_string::String)
    papers = ArxivPaper[]

    entries = split(xml_string, "<entry>")[2:end]

    for entry in entries
        title_match = match(r"<title>(.*?)</title>"s, entry)
        title = title_match !== nothing ? strip(title_match[1]) : ""

        abstract_match = match(r"<summary>(.*?)</summary>"s, entry)
        abstract = abstract_match !== nothing ? strip(abstract_match[1]) : ""

        authors = String[]
        author_matches = eachmatch(r"<name>(.*?)</name>", entry)
        for m in author_matches
            push!(authors, strip(m[1]))
        end

        published_match = match(r"<published>(.*?)</published>", entry)
        published = published_match !== nothing ? strip(published_match[1]) : ""

        categories = String[]
        category_matches = eachmatch(r"<category term=\"(.*?)\"", entry)
        for m in category_matches
            push!(categories, m[1])
        end

        url_match = match(r"<id>(.*?)</id>", entry)
        arxiv_url = url_match !== nothing ? strip(url_match[1]) : ""

        if !isempty(title) && !isempty(abstract)
            push!(papers, ArxivPaper(title, abstract, authors, published, categories, arxiv_url))
        end
    end

    return papers
end

function fetch_papers(search_query::String="", category::String="cs.AI", max_results::Int=200, sort_by::String="submittedDate")
    base_url = "http://export.arxiv.org/api/query"

    if !isempty(search_query)
        query = "all:$(HTTP.escapeuri(search_query))"
        if !isempty(category)
            query *= "+AND+cat:$(category)"
        end
    else
        query = "cat:$(category)"
    end

    params = Dict(
        "search_query" => query,
        "start" => "0",
        "max_results" => string(max_results),
        "sortBy" => sort_by,
        "sortOrder" => "descending"
    )

    try
        response = HTTP.get(base_url; query=params, retry_non_idempotent=true)

        if response.status == 200
            xml_content = String(response.body)
            return parse_arxiv_response(xml_content)
        else
            println("arXiv API returned status: $(response.status)")
            return ArxivPaper[]
        end
    catch e
        println("Error fetching papers: $e")
        return ArxivPaper[]
    end
end

global_index = Index()

function initialize_sample_data()
    println("Index initialized with $(length(global_index.documents)) documents")
end

function update_papers_from_arxiv(categories::Vector{String}=["cs.AI", "cs.LG", "cs.CL", "cs.CV"])
    println("[$(Dates.now())] 論文を取得中...")

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

    println("[$(Dates.now())] $total_added 件の論文を追加しました。総文書数: $(length(global_index.documents))")
    return total_added
end

mutable struct FetcherState
    running::Bool
    last_fetch::DateTime
    fetch_interval::Int
    categories::Vector{String}
end

global fetcher_state = nothing

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

function start_paper_fetching(fetch_interval::Int=1800, categories::Vector{String}=["cs.AI", "cs.LG", "cs.CL", "cs.CV"])
    global fetcher_state = FetcherState(
        true,
        Dates.now(),
        fetch_interval,
        categories
    )

    update_papers_from_arxiv(categories)

    @async fetch_loop()

    println("[$(Dates.now())] 自動論文取得を開始しました（間隔: $(fetch_interval)秒）")
end

function stop_paper_fetching()
    global fetcher_state
    if fetcher_state !== nothing
        fetcher_state.running = false
        println("[$(Dates.now())] 自動論文取得を停止しました")
    end
end

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

function start_server(port=8080, fetch_papers=true, fetch_interval=1800)
    initialize_sample_data()

    if fetch_papers
        categories = ["cs.AI", "cs.LG", "cs.CL", "cs.CV", "cs.IR", "stat.ML"]
        start_paper_fetching(fetch_interval, categories)
    end

    server = HTTP.serve!(handle_request, "0.0.0.0", port)
    println("🚀 サーバーが起動しました: http://localhost:$port")
    if fetch_papers
        println("📚 論文の自動取得が有効です（間隔: $(fetch_interval)秒）")
    end

    try
        wait(server)
    catch e
        if e isa InterruptException
            println("\nサーバーを停止しています...")
            if fetch_papers
                stop_paper_fetching()
            end
            close(server)
        else
            rethrow(e)
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    start_server(8004)
end