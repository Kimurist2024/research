# ============================================================================
# 文書管理モジュール
# ============================================================================

"""
インデックス化されたコンテンツを格納するための文書構造
"""
mutable struct Document
    id::String
    title::String
    content::String
    url::String
    tokens::Vector{String}
    tf::Dict{String, Float64}
    tfidf_vector::Vector{Float64}
end

"""
文書管理と検索機能のための検索インデックス構造
"""
mutable struct Index
    documents::Vector{Document}
    inverted_index::Dict{String, Set{String}}
    idf::Dict{String, Float64}
    vocabulary::Vector{String}
end

Index() = Index(Document[], Dict{String, Set{String}}(), Dict{String, Float64}(), String[])