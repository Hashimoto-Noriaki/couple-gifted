require "rails_helper"

RSpec.describe "POST /api/v1/auth/refresh", type: :request do
  let(:user) { create(:user) }
  let!(:auth_session) { AuthSession.start_for(user) }
  let(:refresh_token) { auth_session.refresh_token }

  def refresh(params)
    post "/api/v1/auth/refresh", params: params, as: :json
  end

  def expect_unauthenticated
    expect(response).to have_http_status(:unauthorized)
    expect(response.media_type).to eq("application/problem+json")
    expect(response.headers["WWW-Authenticate"]).to start_with("Bearer")
    expect(response.parsed_body).to include("type" => "#{ProblemSerializer::BASE_URI}/unauthenticated")
    expect(response.parsed_body.keys).not_to include("access_token", "refresh_token")
  end

  it "200で新しいアクセストークン・リフレッシュトークンを返す（同じ認証セッションのまま）" do
    expect { refresh(refresh_token: refresh_token) }.not_to change(AuthSession, :count)

    assert_schema_conform(200)
    body = response.parsed_body
    expect(body["refresh_token"]).not_to eq(refresh_token)
    expect(body["user"]).to include("id" => user.id)
    expect(AuthSession.find_by_access_token(body["access_token"])).to eq(auth_session)
    expect(AuthSession.find_by_refresh_token(body["refresh_token"])).to eq(auth_session)
  end

  it "一度使ったリフレッシュトークンは、もう使えない（使うたびに入れ替わる）" do
    refresh(refresh_token: refresh_token)

    refresh(refresh_token: refresh_token)

    assert_schema_conform(401)
    expect_unauthenticated
  end

  it "使用済みのリフレッシュトークンが再び使われたら、盗用とみなしてセッションごと失効させる" do
    refresh(refresh_token: refresh_token)
    new_tokens = response.parsed_body

    # 盗んだ側・正規の利用者のどちらかが、使用済みのトークンを使った
    refresh(refresh_token: refresh_token)

    assert_schema_conform(401)
    expect_unauthenticated
    expect(AuthSession.exists?(auth_session.id)).to be(false)

    # 入れ替え後のトークン（もう一方が持っている）も使えなくなる
    refresh(refresh_token: new_tokens["refresh_token"])
    expect(response).to have_http_status(:unauthorized)
    expect(AuthSession.find_by_access_token(new_tokens["access_token"])).to be_nil
  end

  it "新しくもらったリフレッシュトークンで、続けて更新できる" do
    refresh(refresh_token: refresh_token)

    refresh(refresh_token: response.parsed_body["refresh_token"])

    assert_schema_conform(200)
  end

  it "期限切れのリフレッシュトークンなら401（unauthenticated）を返す" do
    travel(AuthSession::REFRESH_TOKEN_TTL + 1.second) do
      refresh(refresh_token: refresh_token)
    end

    assert_schema_conform(401)
    expect_unauthenticated
  end

  it "でたらめなリフレッシュトークンなら401（unauthenticated）を返す" do
    refresh(refresh_token: "garbage")

    assert_schema_conform(401)
    expect_unauthenticated
  end

  it "ログアウト後のリフレッシュトークンなら401（unauthenticated）を返す" do
    auth_session.destroy!

    refresh(refresh_token: refresh_token)

    assert_schema_conform(401)
    expect_unauthenticated
  end

  it "停止中の会員なら401（unauthenticated）を返し、トークンを入れ替えない" do
    user.suspended!

    expect { refresh(refresh_token: refresh_token) }.not_to(change { auth_session.reload.refresh_token_digest })

    assert_schema_conform(401)
    expect_unauthenticated
  end

  it "退会済みの会員なら401（unauthenticated）を返す" do
    user.withdrawn!

    refresh(refresh_token: refresh_token)

    assert_schema_conform(401)
    expect_unauthenticated
  end

  it "同じリフレッシュトークンで同時に更新され、先を越された場合は401（unauthenticated）を返す" do
    # 他のリクエストが、こちらが読み込んだ直後に同じトークンで入れ替えた状況
    allow_any_instance_of(AuthSession).to receive(:rotate_refresh_token!).and_return(false)

    refresh(refresh_token: refresh_token)

    assert_schema_conform(401)
    expect_unauthenticated
  end

  # スキーマに反するリクエストをわざと送るため、レスポンスの検証だけを行う
  it "リフレッシュトークンが無ければ401（unauthenticated）を返す" do
    refresh({})

    assert_response_schema_confirm(401)
    expect_unauthenticated
  end

  it "リフレッシュトークンが文字列でなくても500にせず401（unauthenticated）を返す" do
    refresh(refresh_token: 12_345)

    assert_response_schema_confirm(401)
    expect_unauthenticated
  end
end
