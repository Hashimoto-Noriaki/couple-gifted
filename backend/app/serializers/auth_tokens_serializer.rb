# ログイン・トークン更新の結果（doc/api/openapi.yaml「AuthTokens」）。
# 平文のリフレッシュトークンは発行・入れ替えの直後にしか持てないため、その時点のAuthSessionを渡す
class AuthTokensSerializer
  TOKEN_TYPE = "Bearer".freeze

  def initialize(auth_session)
    @auth_session = auth_session
  end

  def as_json(*)
    {
      access_token: auth_session.access_token,
      refresh_token: auth_session.refresh_token,
      token_type: TOKEN_TYPE,
      expires_in: AuthSession::ACCESS_TOKEN_TTL.to_i,
      user: UserSerializer.new(auth_session.user).as_json
    }
  end

  private

  attr_reader :auth_session
end
