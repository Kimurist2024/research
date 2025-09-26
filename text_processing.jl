# ============================================================================
# テキスト処理モジュール
# ============================================================================

using StatsBase: countmap

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
    total_tokens = length(tokens)
    total_tokens == 0 && return Dict{String, Float64}()

    token_counts = countmap(String.(tokens))
    scaling = 1.0 / total_tokens

    return Dict(token => count * scaling for (token, count) in token_counts)
end