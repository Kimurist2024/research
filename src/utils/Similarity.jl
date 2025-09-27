module Similarity

using LinearAlgebra

export cosine_similarity, jaccard_similarity, euclidean_distance

"""
    cosine_similarity(vec1::Vector{Float64}, vec2::Vector{Float64})

2つのベクトル間のコサイン類似度を計算

# Arguments
- `vec1::Vector{Float64}`: ベクトル1
- `vec2::Vector{Float64}`: ベクトル2

# Returns
- `Float64`: コサイン類似度（0-1の範囲）
"""
function cosine_similarity(vec1::Vector{Float64}, vec2::Vector{Float64})
    # ベクトルの長さチェック
    if length(vec1) != length(vec2)
        throw(ArgumentError("ベクトルの次元が一致しません"))
    end

    # 内積計算
    dot_product = dot(vec1, vec2)

    # ノルム計算
    norm1 = norm(vec1)
    norm2 = norm(vec2)

    # ゼロベクトルの場合
    if norm1 == 0 || norm2 == 0
        return 0.0
    end

    # コサイン類似度
    return dot_product / (norm1 * norm2)
end

"""
    jaccard_similarity(set1::Set{String}, set2::Set{String})

2つの集合間のJaccard類似度を計算

# Arguments
- `set1::Set{String}`: 集合1
- `set2::Set{String}`: 集合2

# Returns
- `Float64`: Jaccard類似度（0-1の範囲）
"""
function jaccard_similarity(set1::Set{String}, set2::Set{String})
    intersection_size = length(intersect(set1, set2))
    union_size = length(union(set1, set2))

    if union_size == 0
        return 0.0
    end

    return intersection_size / union_size
end

"""
    euclidean_distance(vec1::Vector{Float64}, vec2::Vector{Float64})

2つのベクトル間のユークリッド距離を計算

# Arguments
- `vec1::Vector{Float64}`: ベクトル1
- `vec2::Vector{Float64}`: ベクトル2

# Returns
- `Float64`: ユークリッド距離
"""
function euclidean_distance(vec1::Vector{Float64}, vec2::Vector{Float64})
    if length(vec1) != length(vec2)
        throw(ArgumentError("ベクトルの次元が一致しません"))
    end

    return norm(vec1 - vec2)
end

end # module