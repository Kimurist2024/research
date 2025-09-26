# ============================================================================
# ARXIV APIクライアントモジュール
# ============================================================================

using HTTP

"""
arXiv論文を表現する構造体
"""
struct ArxivPaper
    title::String
    abstract::String
    authors::Vector{String}
    published::String
    categories::Vector{String}
    arxiv_url::String
end

"""
arXiv APIレスポンスXMLをArxivPaper構造体にパースする
"""
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

"""
arXiv APIから論文を取得する
"""
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