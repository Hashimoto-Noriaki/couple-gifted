# 認証セッション。ログインのたびに1行作る（doc/er-and-db-design.md「auth_sessions」、決定事項ログ #30）。
# - アクセストークン：このセッションのsigned_id（Rails標準の署名付きID）。DBには保存しない
# - リフレッシュトークン：ランダム値。DBにはSHA-256のダイジェストだけを保存する
#   （高エントロピーの乱数なのでbcryptのような低速ハッシュは不要。ダイジェストで直接検索できる）
class AuthSession < ApplicationRecord
  ACCESS_TOKEN_TTL = 15.minutes
  REFRESH_TOKEN_TTL = 30.days
  ACCESS_TOKEN_PURPOSE = :access

  belongs_to :user

  # どの作り方（start_for・user.auth_sessions.create!等）でも必ずリフレッシュトークンを発行する
  before_validation :assign_new_refresh_token, on: :create

  # 平文のリフレッシュトークン。発行・入れ替えの直後にだけメモリ上に持つ（DBには無い）
  attr_reader :refresh_token

  def self.start_for(user)
    create!(user: user)
  end

  def self.find_by_access_token(token)
    return if token.blank?

    find_signed(token, purpose: ACCESS_TOKEN_PURPOSE)
  end

  def self.find_by_refresh_token(token)
    return if token.blank?

    where("refresh_token_expires_at > ?", Time.current).find_by(refresh_token_digest: digest(token.to_s))
  end

  # 入れ替え済みの古いリフレッシュトークンが使われたら、盗まれたとみなしてセッションごと消す。
  # 盗んだ側と正規の利用者のどちらが先に更新したかはサーバから区別できないため、両方を締め出して
  # ログインし直させる（同じセッションのアクセストークンも即座に無効になる）。消したらtrue
  def self.revoke_by_reused_refresh_token(token)
    return false if token.blank?

    where(previous_refresh_token_digest: digest(token.to_s)).delete_all.positive?
  end

  def self.digest(token)
    Digest::SHA256.hexdigest(token)
  end

  def access_token
    signed_id(purpose: ACCESS_TOKEN_PURPOSE, expires_in: ACCESS_TOKEN_TTL)
  end

  # リフレッシュトークンを入れ替える。同じトークンで同時に更新された場合に両方を成功させない
  # （1本のトークンから2つの有効なトークンが生まれるのを防ぐ）ため、古いダイジェストのままの行だけを
  # 書き換え、先を越されていればfalseを返す
  def rotate_refresh_token!
    old_digest = refresh_token_digest
    assign_new_refresh_token
    self.previous_refresh_token_digest = old_digest
    self.updated_at = Time.current
    updated = self.class.where(id: id, refresh_token_digest: old_digest)
      .update_all(refresh_token_digest: refresh_token_digest,
                  refresh_token_expires_at: refresh_token_expires_at,
                  previous_refresh_token_digest: previous_refresh_token_digest,
                  updated_at: updated_at)

    if updated == 1
      # update_allはメモリ上の変更を「保存済み」にしない。残すと後のsaveが上の条件付き更新を
      # 経由せずに書き込んでしまうため、DBと一致したことを明示する
      changes_applied
      true
    else
      restore_attributes
      @refresh_token = nil
      false
    end
  end

  private

  def assign_new_refresh_token
    @refresh_token = SecureRandom.urlsafe_base64(32)
    self.refresh_token_digest = self.class.digest(@refresh_token)
    self.refresh_token_expires_at = REFRESH_TOKEN_TTL.from_now
  end
end
