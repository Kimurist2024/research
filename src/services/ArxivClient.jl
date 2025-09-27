module ArxivClient

using HTTP
using Dates
using Logging

export ArxivPaper, fetch_papers, search_arxiv

"""
    ArxivPaper

arXiv論文のデータ構造
"""
struct ArxivPaper
    title::String
    abstract::String
    authors::Vector{String}
    published::String
    categories::Vector{String}
    arxiv_url::String
    pdf_url::String
end

"""
    parse_arxiv_response(xml_string::String)

arXiv APIのXMLレスポンスをパース

# Arguments
- `xml_string::String`: XMLレスポンス文字列

# Returns
- `Vector{ArxivPaper}`: パースされた論文のリスト
"""
function parse_arxiv_response(xml_string::String)
    papers = ArxivPaper[]

    # エントリーごとに分割
    entries = split(xml_string, "<entry>")[2:end]

    for entry in entries
        try
            # タイトル抽出
            title_match = match(r"<title>(.*?)</title>"s, entry)
            title = title_match !== nothing ? strip(title_match[1]) : ""

            # アブストラクト抽出
            abstract_match = match(r"<summary>(.*?)</summary>"s, entry)
            abstract = abstract_match !== nothing ? strip(abstract_match[1]) : ""

            # 著者抽出
            authors = String[]
            author_matches = eachmatch(r"<name>(.*?)</name>", entry)
            for m in author_matches
                push!(authors, strip(m[1]))
            end

            # 公開日抽出
            published_match = match(r"<published>(.*?)</published>", entry)
            published = published_match !== nothing ? strip(published_match[1]) : ""

            # カテゴリ抽出
            categories = String[]
            category_matches = eachmatch(r"<category term=\"(.*?)\"", entry)
            for m in category_matches
                push!(categories, m[1])
            end

            # URL抽出
            url_match = match(r"<id>(.*?)</id>", entry)
            arxiv_url = url_match !== nothing ? strip(url_match[1]) : ""

            # PDF URL生成
            pdf_url = replace(arxiv_url, "abs" => "pdf") * ".pdf"

            # 有効なデータのみ追加
            if !isempty(title) && !isempty(abstract)
                push!(papers, ArxivPaper(
                    title,
                    abstract,
                    authors,
                    published,
                    categories,
                    arxiv_url,
                    pdf_url
                ))
            end
        catch e
            @warn "Failed to parse entry" exception=e
        end
    end

    return papers
end

"""
    fetch_papers(; search_query::String="", category::String="cs.AI", max_results::Int=100, sort_by::String="submittedDate")

arXivから論文を取得

# Arguments
- `search_query::String`: 検索クエリ（オプション）
- `category::String`: カテゴリ（デフォルト: "cs.AI"）
- `max_results::Int`: 最大取得数（デフォルト: 100）
- `sort_by::String`: ソート順（デフォルト: "submittedDate"）

# Returns
- `Vector{ArxivPaper}`: 取得した論文のリスト
"""
function fetch_papers(;
    search_query::String="",
    category::String="cs.AI",
    max_results::Int=100,
    sort_by::String="submittedDate"
)
    base_url = "http://export.arxiv.org/api/query"

    # クエリ構築
    if !isempty(search_query)
        query = "all:$(HTTP.escapeuri(search_query))"
        if !isempty(category)
            query *= "+AND+cat:$(category)"
        end
    else
        query = "cat:$(category)"
    end

    # パラメータ設定
    params = Dict(
        "search_query" => query,
        "start" => "0",
        "max_results" => string(max_results),
        "sortBy" => sort_by,
        "sortOrder" => "descending"
    )

    @info "Fetching papers from arXiv" category=category max_results=max_results

    try
        # APIリクエスト
        response = HTTP.get(base_url; query=params, retry_non_idempotent=true, readtimeout=30)

        if response.status == 200
            xml_content = String(response.body)
            papers = parse_arxiv_response(xml_content)
            @info "Papers fetched successfully" count=length(papers)
            return papers
        else
            @error "arXiv API error" status=response.status
            return ArxivPaper[]
        end
    catch e
        @error "Failed to fetch papers" exception=e
        return ArxivPaper[]
    end
end

"""
    search_arxiv(query::String; max_results::Int=50)

arXivで論文を検索

# Arguments
- `query::String`: 検索クエリ
- `max_results::Int`: 最大取得数

# Returns
- `Vector{ArxivPaper}`: 検索結果の論文リスト
"""
function search_arxiv(query::String; max_results::Int=50)
    return fetch_papers(
        search_query=query,
        category="",
        max_results=max_results,
        sort_by="relevance"
    )
end

end # module