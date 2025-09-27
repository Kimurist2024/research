module UserManager

using Dates
using JSON3

export UserSession, add_search_history, get_search_history, add_favorite, remove_favorite, get_favorites, get_user_stats

# ユーザーセッション構造体
mutable struct UserSession
    id::String
    search_count::Int
    search_history::Vector{Dict{String, Any}}
    favorites::Set{String}
    favorite_details::Dict{String, Any}
    last_access::DateTime
    created_at::DateTime
end

# グローバルユーザーセッション管理
const USER_SESSIONS = Dict{String, UserSession}()
const DEFAULT_USER_ID = "default_user"

"""
    get_or_create_user(user_id::String = DEFAULT_USER_ID)

ユーザーセッションを取得または作成
"""
function get_or_create_user(user_id::String = DEFAULT_USER_ID)
    if !haskey(USER_SESSIONS, user_id)
        USER_SESSIONS[user_id] = UserSession(
            user_id,
            0,
            Vector{Dict{String, Any}}(),
            Set{String}(),
            Dict{String, Any}(),
            now(),
            now()
        )
    end
    USER_SESSIONS[user_id].last_access = now()
    return USER_SESSIONS[user_id]
end

"""
    add_search_history(query::String, results_count::Int, user_id::String = DEFAULT_USER_ID)

検索履歴を追加
"""
function add_search_history(query::String, results_count::Int, user_id::String = DEFAULT_USER_ID)
    user = get_or_create_user(user_id)

    # 検索カウントを増加
    user.search_count += 1

    # 検索履歴を追加（最新10件まで保持）
    search_entry = Dict{String, Any}(
        "query" => query,
        "results_count" => results_count,
        "timestamp" => now(),
        "formatted_time" => Dates.format(now(), "yyyy年mm月dd日 HH:MM")
    )

    pushfirst!(user.search_history, search_entry)

    # 履歴を10件まで制限
    if length(user.search_history) > 10
        resize!(user.search_history, 10)
    end

    return user.search_count
end

"""
    get_search_history(user_id::String = DEFAULT_USER_ID)

検索履歴を取得
"""
function get_search_history(user_id::String = DEFAULT_USER_ID)
    user = get_or_create_user(user_id)
    return user.search_history
end

"""
    add_favorite(paper_url::String, paper_title::String, user_id::String = DEFAULT_USER_ID)

お気に入り論文を追加
"""
function add_favorite(paper_url::String, paper_title::String, user_id::String = DEFAULT_USER_ID)
    user = get_or_create_user(user_id)
    push!(user.favorites, paper_url)

    # お気に入り詳細情報を保存
    user.favorite_details[paper_url] = Dict{String, Any}(
        "title" => paper_title,
        "added_at" => now(),
        "formatted_time" => Dates.format(now(), "yyyy年mm月dd日")
    )

    return length(user.favorites)
end

"""
    remove_favorite(paper_url::String, user_id::String = DEFAULT_USER_ID)

お気に入り論文を削除
"""
function remove_favorite(paper_url::String, user_id::String = DEFAULT_USER_ID)
    user = get_or_create_user(user_id)
    delete!(user.favorites, paper_url)
    delete!(user.favorite_details, paper_url)

    return length(user.favorites)
end

"""
    get_favorites(user_id::String = DEFAULT_USER_ID)

お気に入り論文を取得
"""
function get_favorites(user_id::String = DEFAULT_USER_ID)
    user = get_or_create_user(user_id)
    return user.favorites
end

"""
    is_favorite(paper_url::String, user_id::String = DEFAULT_USER_ID)

論文がお気に入りかどうか確認
"""
function is_favorite(paper_url::String, user_id::String = DEFAULT_USER_ID)
    user = get_or_create_user(user_id)
    return paper_url in user.favorites
end

"""
    get_user_stats(user_id::String = DEFAULT_USER_ID)

ユーザー統計を取得
"""
function get_user_stats(user_id::String = DEFAULT_USER_ID)
    user = get_or_create_user(user_id)

    return Dict{String, Any}(
        "search_count" => user.search_count,
        "favorites_count" => length(user.favorites),
        "last_access" => Dates.format(user.last_access, "yyyy年mm月dd日 HH:MM"),
        "member_since" => Dates.format(user.created_at, "yyyy年mm月dd日"),
        "history_count" => length(user.search_history)
    )
end

end # module