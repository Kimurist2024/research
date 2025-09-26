# ============================================================================
# 検索エンジンモジュール
# ============================================================================

include("document.jl")
include("text_processing.jl")

using LinearAlgebra

"""
検索インデックスに新しい文書を追加する
"""
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

"""
インデックス内のすべての語についてIDF（逆文書頻度）を計算する
"""
function calculate_idf!(index::Index)
    n_docs = length(index.documents)

    for (term, doc_ids) in index.inverted_index
        df = length(doc_ids)
        index.idf[term] = log(n_docs / df)
    end

    index.vocabulary = sort(collect(keys(index.idf)))
end

"""
インデックス内のすべての文書のTF-IDFベクトルを計算する
"""
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

"""
2つのベクトル間のコサイン類似度を計算する
"""
function cosine_similarity(vec1::Vector{Float64}, vec2::Vector{Float64})
    dot_product = dot(vec1, vec2)
    norm1 = norm(vec1)
    norm2 = norm(vec2)

    if norm1 == 0 || norm2 == 0
        return 0.0
    end

    return dot_product / (norm1 * norm2)
end

"""
クエリに一致する文書をインデックスから検索する
"""
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