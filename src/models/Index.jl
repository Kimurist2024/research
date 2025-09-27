module IndexModel

using ..DocumentModel

export Index, create_index, add_document!, get_document, clear_index!

"""
    Index

検索エンジンのインデックス構造体

# Fields
- `documents::Vector{Document}`: ドキュメントのリスト
- `inverted_index::Dict{String, Set{String}}`: 転置インデックス（単語 → ドキュメントIDのセット）
- `idf::Dict{String, Float64}`: 逆文書頻度マップ
- `vocabulary::Vector{String}`: 語彙リスト
- `doc_map::Dict{String, Document}`: ドキュメントIDからDocumentへのマップ
"""
mutable struct Index
    documents::Vector{Document}
    inverted_index::Dict{String, Set{String}}
    idf::Dict{String, Float64}
    vocabulary::Vector{String}
    doc_map::Dict{String, Document}
end

"""
    create_index()

空のインデックスを作成
"""
function create_index()
    return Index(
        Document[],
        Dict{String, Set{String}}(),
        Dict{String, Float64}(),
        String[],
        Dict{String, Document}()
    )
end

"""
    add_document!(index::Index, doc::Document)

インデックスにドキュメントを追加
"""
function add_document!(index::Index, doc::Document)
    push!(index.documents, doc)
    index.doc_map[doc.id] = doc
    return doc.id
end

"""
    get_document(index::Index, doc_id::String)

IDでドキュメントを取得
"""
function get_document(index::Index, doc_id::String)
    return get(index.doc_map, doc_id, nothing)
end

"""
    clear_index!(index::Index)

インデックスをクリア
"""
function clear_index!(index::Index)
    empty!(index.documents)
    empty!(index.inverted_index)
    empty!(index.idf)
    empty!(index.vocabulary)
    empty!(index.doc_map)
end

end # module