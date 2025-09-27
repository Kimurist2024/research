module TextProcessor

export tokenize, calculate_tf, calculate_tfidf

"""
    tokenize(text::String)

テキストをトークン化して単語のリストを返す

# Arguments
- `text::String`: 入力テキスト

# Returns
- `Vector{String}`: トークン化された単語のリスト
"""
function tokenize(text::String)
    # テキストを小文字化
    lowercase_text = lowercase(text)

    # 日本語、英語、記号で分割
    words = split(lowercase_text, r"[\s\-_,;.!?()「」『』【】\[\]{}\"'`]+")

    # 空の要素と1文字の要素を除外
    filtered_words = filter(w -> length(w) > 1, words)

    return collect(filtered_words)
end

"""
    calculate_tf(tokens::Vector{<:AbstractString})

単語頻度（Term Frequency）を計算

# Arguments
- `tokens::Vector{<:AbstractString}`: トークンのリスト

# Returns
- `Dict{String, Float64}`: 単語とその頻度のマップ
"""
function calculate_tf(tokens::Vector{<:AbstractString})
    tf = Dict{String, Float64}()
    total = length(tokens)

    # 空のトークンリストの場合
    if total == 0
        return tf
    end

    # 各トークンの出現回数をカウント
    for token in tokens
        tf[token] = get(tf, token, 0.0) + 1.0
    end

    # 正規化（頻度を総単語数で割る）
    for token in keys(tf)
        tf[token] = tf[token] / total
    end

    return tf
end

"""
    calculate_tfidf(tf::Dict{String, Float64}, idf::Dict{String, Float64})

TF-IDFスコアを計算

# Arguments
- `tf::Dict{String, Float64}`: 単語頻度
- `idf::Dict{String, Float64}`: 逆文書頻度

# Returns
- `Dict{String, Float64}`: TF-IDFスコアのマップ
"""
function calculate_tfidf(tf::Dict{String, Float64}, idf::Dict{String, Float64})
    tfidf = Dict{String, Float64}()

    for (term, tf_value) in tf
        idf_value = get(idf, term, 0.0)
        tfidf[term] = tf_value * idf_value
    end

    return tfidf
end

end # module