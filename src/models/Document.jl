module DocumentModel

export Document, create_document

"""
    Document

検索エンジン用のドキュメント構造体

# Fields
- `id::String`: ドキュメントの一意識別子
- `title::String`: ドキュメントのタイトル
- `content::String`: ドキュメントの内容
- `url::String`: ドキュメントのURL
- `tokens::Vector{String}`: トークナイズされた単語リスト
- `tf::Dict{String, Float64}`: 単語頻度マップ
- `tfidf_vector::Vector{Float64}`: TF-IDFベクトル
- `metadata::Dict{String, Any}`: その他のメタデータ
"""
mutable struct Document
    id::String
    title::String
    content::String
    url::String
    tokens::Vector{String}
    tf::Dict{String, Float64}
    tfidf_vector::Vector{Float64}
    metadata::Dict{String, Any}
end

"""
    create_document(id, title, content, url; metadata=Dict())

新しいDocumentインスタンスを作成

# Arguments
- `id::String`: ドキュメントID
- `title::String`: タイトル
- `content::String`: 内容
- `url::String`: URL
- `metadata::Dict`: オプションのメタデータ
"""
function create_document(
    id::String,
    title::String,
    content::String,
    url::String;
    metadata::Dict{String, Any}=Dict{String, Any}()
)
    return Document(
        id,
        title,
        content,
        url,
        String[],
        Dict{String, Float64}(),
        Float64[],
        metadata
    )
end

end # module