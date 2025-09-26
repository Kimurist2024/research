# ============================================================================
# テキスト処理モジュール
# ============================================================================

"""
テキストを単語に分割し、句読点と短い単語を除去する
"""
function tokenize(text::String)
    lowercase_text = lowercase(text)
    words = split(lowercase_text, r"[\s\-_,;.!?()「」『』【】\[\]{}\"'`]+")
    return filter(w -> length(w) > 1, words)
end

"""
与えられたトークンの単語頻度を計算する
"""
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