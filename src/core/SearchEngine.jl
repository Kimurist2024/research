module SearchEngine

using ..DocumentModel
using ..IndexModel
using ..TextProcessor
using ..Similarity
using Logging

export SearchResult, add_document_to_index!, calculate_idf!, calculate_tfidf_vectors!, search, build_index!

"""
    SearchResult

検索結果の構造体
"""
struct SearchResult
    title::String
    content::String
    url::String
    score::Float64
    metadata::Dict{String, Any}
end

# グローバルインデックス
global_index = create_index()

"""
    get_global_index()

グローバルインデックスを取得
"""
function get_global_index()
    return global_index
end

"""
    add_document_to_index!(title::String, content::String, url::String; metadata=Dict())

ドキュメントをインデックスに追加

# Arguments
- `title::String`: ドキュメントのタイトル
- `content::String`: ドキュメントの内容
- `url::String`: ドキュメントのURL
- `metadata::Dict`: オプションのメタデータ
"""
function add_document_to_index!(
    title::String,
    content::String,
    url::String;
    metadata::Dict{String, Any}=Dict{String, Any}()
)
    index = global_index
    doc_id = string(length(index.documents) + 1)

    # ドキュメント作成
    doc = create_document(doc_id, title, content, url; metadata=metadata)

    # テキスト処理
    full_text = title * " " * content
    doc.tokens = tokenize(full_text)
    doc.tf = calculate_tf(doc.tokens)

    # インデックスに追加
    add_document!(index, doc)

    # 転置インデックスの更新
    for token in Set(doc.tokens)
        if !haskey(index.inverted_index, token)
            index.inverted_index[token] = Set{String}()
        end
        push!(index.inverted_index[token], doc_id)
    end

    @debug "Document added" doc_id=doc_id title=title

    return doc_id
end

"""
    calculate_idf!(index::Index=global_index)

逆文書頻度（IDF）を計算
"""
function calculate_idf!(index::Index=global_index)
    n_docs = length(index.documents)

    if n_docs == 0
        @warn "No documents in index"
        return
    end

    # 各単語のIDFを計算
    for (term, doc_ids) in index.inverted_index
        df = length(doc_ids)  # Document Frequency
        index.idf[term] = log(n_docs / df)
    end

    # 語彙をソート
    index.vocabulary = sort(collect(keys(index.idf)))

    @info "IDF calculated" terms=length(index.vocabulary) documents=n_docs
end

"""
    calculate_tfidf_vectors!(index::Index=global_index)

全ドキュメントのTF-IDFベクトルを計算
"""
function calculate_tfidf_vectors!(index::Index=global_index)
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

    @info "TF-IDF vectors calculated" documents=length(index.documents)
end

"""
    search(query::String; top_k::Int=10, min_score::Float64=0.0)

クエリで検索を実行

# Arguments
- `query::String`: 検索クエリ
- `top_k::Int`: 返す結果の最大数
- `min_score::Float64`: 最小スコア閾値

# Returns
- `Vector{SearchResult}`: 検索結果のリスト
"""
function search(query::String; top_k::Int=10, min_score::Float64=0.0)
    index = global_index

    # クエリのトークン化
    query_tokens = tokenize(query)

    if isempty(query_tokens)
        @warn "Empty query tokens"
        return SearchResult[]
    end

    # クエリのTF計算
    query_tf = calculate_tf(query_tokens)

    # クエリベクトル作成
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

    # 各ドキュメントとの類似度計算
    scores = Tuple{Document, Float64}[]
    for doc in index.documents
        score = cosine_similarity(doc.tfidf_vector, query_vector)
        if score > min_score
            push!(scores, (doc, score))
        end
    end

    # スコアでソート
    sort!(scores, by=x->x[2], rev=true)

    # 結果作成
    results = SearchResult[]
    for i in 1:min(top_k, length(scores))
        doc, score = scores[i]
        push!(results, SearchResult(
            doc.title,
            doc.content,
            doc.url,
            score,
            doc.metadata
        ))
    end

    @info "Search completed" query=query results=length(results)

    return results
end

"""
    build_index!()

インデックスを構築（IDF計算とTF-IDFベクトル計算）
"""
function build_index!()
    calculate_idf!()
    calculate_tfidf_vectors!()
end

"""
    clear_index!()

インデックスをクリア
"""
function clear_index!()
    IndexModel.clear_index!(global_index)
    @info "Index cleared"
end

end # module