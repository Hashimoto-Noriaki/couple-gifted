require "rails_helper"

RSpec.describe "DELETE /api/v1/auth/sign_out", type: :request do
  let(:user) { create(:user) }
  let!(:auth_session) { AuthSession.start_for(user) }
  let(:access_token) { auth_session.access_token }

  def sign_out(token)
    headers = token ? { "Authorization" => "Bearer #{token}" } : {}
    delete "/api/v1/auth/sign_out", headers: headers, as: :json
  end

  def expect_unauthenticated
    expect(response).to have_http_status(:unauthorized)
    expect(response.media_type).to eq("application/problem+json")
    expect(response.headers["WWW-Authenticate"]).to start_with("Bearer")
    expect(response.parsed_body).to include("type" => "#{ProblemSerializer::BASE_URI}/unauthenticated")
  end

  it "204を返し、いまの認証セッションを消す" do
    expect { sign_out(access_token) }.to change(AuthSession, :count).by(-1)

    assert_schema_conform(204)
    expect(AuthSession.exists?(auth_session.id)).to be(false)
  end

  it "ログアウト後は、同じアクセストークンもリフレッシュトークンも使えない" do
    refresh_token = auth_session.refresh_token
    sign_out(access_token)

    sign_out(access_token)
    expect_unauthenticated

    post "/api/v1/auth/refresh", params: { refresh_token: refresh_token }, as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it "認証方式名（Bearer）の大文字小文字・空白の数の違いは受け付ける（RFC 7235）" do
    delete "/api/v1/auth/sign_out", headers: { "Authorization" => "bearer  #{access_token}" }, as: :json

    assert_schema_conform(204)
  end

  it "他の端末のログイン（別の認証セッション）は消さない" do
    other_session = AuthSession.start_for(user)

    sign_out(access_token)

    expect(AuthSession.exists?(other_session.id)).to be(true)
  end

  describe "認証できない場合" do
    it "Authorizationヘッダが無ければ401（unauthenticated）を返し、何も消さない" do
      expect { sign_out(nil) }.not_to change(AuthSession, :count)

      assert_schema_conform(401)
      expect_unauthenticated
    end

    it "でたらめなアクセストークンなら401（unauthenticated）を返す" do
      sign_out("garbage")

      assert_schema_conform(401)
      expect_unauthenticated
    end

    it "Bearer以外の形式なら401（unauthenticated）を返す" do
      delete "/api/v1/auth/sign_out", headers: { "Authorization" => "Basic #{access_token}" }, as: :json

      assert_schema_conform(401)
      expect_unauthenticated
    end

    it "期限切れのアクセストークンなら401（unauthenticated）を返し、何も消さない" do
      # letは遅延評価のため、時刻を進める前に発行しておく
      token = access_token

      travel(AuthSession::ACCESS_TOKEN_TTL + 1.second) do
        expect { sign_out(token) }.not_to change(AuthSession, :count)
      end

      assert_schema_conform(401)
      expect_unauthenticated
    end

    it "停止中の会員のアクセストークンなら401（unauthenticated）を返す" do
      user.suspended!

      sign_out(access_token)

      assert_schema_conform(401)
      expect_unauthenticated
    end

    it "退会済みの会員のアクセストークンなら401（unauthenticated）を返す" do
      user.withdrawn!

      sign_out(access_token)

      assert_schema_conform(401)
      expect_unauthenticated
    end
  end
end
