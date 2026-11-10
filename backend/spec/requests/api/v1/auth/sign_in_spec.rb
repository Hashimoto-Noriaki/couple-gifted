require "rails_helper"

RSpec.describe "POST /api/v1/auth/sign_in", type: :request do
  let!(:user) { create(:user, email: "hanako@example.com", password: "password123") }
  let(:valid_params) { { email: "hanako@example.com", password: "password123" } }

  def sign_in(params)
    post "/api/v1/auth/sign_in", params: params, as: :json
  end

  it "200でアクセストークン・リフレッシュトークン・会員の情報を返し、認証セッションを作る" do
    expect { sign_in(valid_params) }.to change(AuthSession, :count).by(1)

    assert_schema_conform(200)
    body = response.parsed_body
    expect(body).to include("token_type" => "Bearer", "expires_in" => AuthSession::ACCESS_TOKEN_TTL.to_i)
    expect(body["user"]).to include("id" => user.id, "email" => "hanako@example.com")

    session = AuthSession.last
    expect(session.user).to eq(user)
    expect(AuthSession.find_by_access_token(body["access_token"])).to eq(session)
    expect(AuthSession.find_by_refresh_token(body["refresh_token"])).to eq(session)
  end

  it "平文のリフレッシュトークンをDBに保存しない" do
    sign_in(valid_params)

    expect(AuthSession.last.refresh_token_digest).not_to eq(response.parsed_body["refresh_token"])
  end

  it "メールアドレスの大文字小文字・前後の空白の違いは無視して照合する" do
    sign_in(valid_params.merge(email: "  Hanako@Example.COM "))

    assert_schema_conform(200)
  end

  describe "ログインできない場合" do
    # 失敗の理由を区別しない（doc/use-cases.md「ログインする」、doc/api-design.md「設計上の判断 7」）
    def expect_invalid_credentials
      expect(response).to have_http_status(:unauthorized)
      expect(response.media_type).to eq("application/problem+json")
      expect(response.headers["WWW-Authenticate"]).to start_with("Bearer")
      expect(response.parsed_body).to include(
        "type" => "#{ProblemSerializer::BASE_URI}/invalid-credentials", "status" => 401
      )
    end

    def body_without_request_id
      response.parsed_body.except("request_id")
    end

    it "パスワードが違えば401（invalid-credentials）を返し、認証セッションを作らない" do
      expect { sign_in(valid_params.merge(password: "wrong-password")) }.not_to change(AuthSession, :count)

      assert_schema_conform(401)
      expect_invalid_credentials
      expect(response.parsed_body.keys).not_to include("access_token", "refresh_token")
    end

    it "登録されていないメールアドレスでも、パスワード違いと同じ応答を返す（登録の有無を伝えない）" do
      sign_in(valid_params.merge(password: "wrong-password"))
      wrong_password_body = body_without_request_id

      sign_in(valid_params.merge(email: "nobody@example.com"))

      assert_schema_conform(401)
      expect(body_without_request_id).to eq(wrong_password_body)
    end

    it "退会済みの会員は、パスワードが正しくてもパスワード違いと同じ応答を返す" do
      sign_in(valid_params.merge(password: "wrong-password"))
      wrong_password_body = body_without_request_id

      user.withdrawn!
      expect { sign_in(valid_params) }.not_to change(AuthSession, :count)

      assert_schema_conform(401)
      expect(body_without_request_id).to eq(wrong_password_body)
    end

    it "停止中の会員は、パスワードが正しければ403（account-suspended）を返し、認証セッションを作らない" do
      user.suspended!

      expect { sign_in(valid_params) }.not_to change(AuthSession, :count)

      assert_schema_conform(403)
      expect(response.media_type).to eq("application/problem+json")
      expect(response.parsed_body).to include("type" => "#{ProblemSerializer::BASE_URI}/account-suspended")
    end

    it "停止中の会員でも、パスワードが違えば401（invalid-credentials）を返す（本人以外に停止の事実を伝えない）" do
      user.suspended!

      sign_in(valid_params.merge(password: "wrong-password"))

      assert_schema_conform(401)
      expect_invalid_credentials
    end

    # 以下はスキーマに反するリクエストをわざと送るため、レスポンスの検証だけを行う
    it "パスワードが無ければ401（invalid-credentials）を返す" do
      sign_in(valid_params.except(:password))

      assert_response_schema_confirm(401)
      expect_invalid_credentials
    end

    it "メールアドレスが無ければ401（invalid-credentials）を返す" do
      sign_in(valid_params.except(:email))

      assert_response_schema_confirm(401)
      expect_invalid_credentials
    end

    it "メールアドレスが文字列でなくても500にせず401（invalid-credentials）を返す" do
      sign_in(valid_params.merge(email: 12_345))

      assert_response_schema_confirm(401)
      expect_invalid_credentials
    end
  end
end
