require "rails_helper"

RSpec.describe "POST /api/v1/auth/sign_up", type: :request do
  let(:valid_params) { { email: "hanako@example.com", password: "password123", nickname: "はなこ" } }

  def sign_up(params)
    post "/api/v1/auth/sign_up", params: params, as: :json
  end

  def error_pairs
    response.parsed_body["errors"].map { |e| [ e["field"], e["code"] ] }
  end

  # 登録と同時にログイン状態にする（doc/use-cases.md「新規登録する」、doc/api-design.md「設計上の判断 7」）
  it "会員と認証セッションを作り、201でアクセストークン・リフレッシュトークン・会員の情報を返す" do
    expect { sign_up(valid_params) }
      .to change(User, :count).by(1)
      .and change(AuthSession, :count).by(1)

    assert_schema_conform(201)
    user = User.last
    body = response.parsed_body
    expect(body).to include("token_type" => "Bearer", "expires_in" => AuthSession::ACCESS_TOKEN_TTL.to_i)
    expect(body["user"]).to include(
      "id" => user.id,
      "email" => "hanako@example.com",
      "nickname" => "はなこ",
      "age_band" => nil,
      "area_id" => nil,
      "has_children" => false,
      "relationship_stage" => nil
    )

    session = AuthSession.last
    expect(session.user).to eq(user)
    expect(AuthSession.find_by_access_token(body["access_token"])).to eq(session)
    expect(AuthSession.find_by_refresh_token(body["refresh_token"])).to eq(session)
  end

  it "返したアクセストークンで、更新を挟まずにそのままログアウトでき、認証セッションが消える" do
    sign_up(valid_params)
    access_token = response.parsed_body["access_token"]

    expect {
      delete "/api/v1/auth/sign_out", headers: { "Authorization" => "Bearer #{access_token}" }, as: :json
    }.to change(AuthSession, :count).by(-1)
    expect(response).to have_http_status(:no_content)
  end

  it "返したリフレッシュトークンで、そのままトークンを更新できる" do
    sign_up(valid_params)
    refresh_token = response.parsed_body["refresh_token"]

    post "/api/v1/auth/refresh", params: { refresh_token: refresh_token }, as: :json
    expect(response).to have_http_status(:ok)
  end

  it "パスワードを平文で返さない・保存しない" do
    sign_up(valid_params)

    body = response.parsed_body
    expect(body.keys).not_to include("password", "password_digest")
    expect(body["user"].keys).not_to include("password", "password_digest")
    expect(User.last.password_digest).not_to eq("password123")
  end

  it "認証セッションを作れなければ、会員も作らない（ログイン状態にならない会員を残さない）" do
    allow(AuthSession).to receive(:start_for).and_raise(ActiveRecord::ActiveRecordError, "認証セッションを作れなかった")

    expect { sign_up(valid_params) }.to raise_error(ActiveRecord::ActiveRecordError)
    expect(User.exists?(email: "hanako@example.com")).to be(false)
  end

  it "認証セッション側の一意制約違反は、メールアドレスの重複（422 taken）として返さない" do
    # メールアドレスは重複していないのに「使われています」と伝えてしまわないため。想定外の失敗として扱う
    allow(AuthSession).to receive(:start_for).and_raise(ActiveRecord::RecordNotUnique)

    expect { sign_up(valid_params) }.to raise_error(ActiveRecord::RecordNotUnique)
    expect(User.exists?(email: "hanako@example.com")).to be(false)
  end

  it "会員の状態（status）はクライアントから指定できず、activeで作られる" do
    sign_up(valid_params.merge(status: "suspended"))

    expect(response).to have_http_status(:created)
    expect(User.last).to be_active
  end

  describe "入力内容に誤りがある場合" do
    # 以下の多くはスキーマに反するリクエスト（必須項目の欠落・形式違反）をわざと送るため、
    # リクエスト側の検証はせず、レスポンスがValidationProblemに沿うかだけを確かめる
    # （assert_response_schema_confirm）
    it "メールアドレスが登録済みなら422（taken）を返し、会員も認証セッションも作らない" do
      create(:user, email: "hanako@example.com")

      expect { sign_up(valid_params) }.not_to change { [ User.count, AuthSession.count ] }

      assert_schema_conform(422)
      expect(response.media_type).to eq("application/problem+json")
      expect(error_pairs).to contain_exactly([ "email", "taken" ])
    end

    it "停止済みの会員と同じメールアドレスでも、登録済みと同じ応答を返す（停止の事実を伝えない）" do
      create(:user, email: "taken@example.com")
      sign_up(valid_params.merge(email: "taken@example.com"))
      taken_body = response.parsed_body.except("request_id")

      create(:user, email: "hanako@example.com", status: :suspended)
      sign_up(valid_params)

      assert_schema_conform(422)
      expect(response.parsed_body.except("request_id")).to eq(taken_body)
    end

    it "メールアドレスの形式でなければ422（invalid）を返す" do
      sign_up(valid_params.merge(email: "not-an-email"))

      assert_response_schema_confirm(422)
      expect(error_pairs).to contain_exactly([ "email", "invalid" ])
    end

    it "パスワードが短すぎれば422（too_short）を返す" do
      sign_up(valid_params.merge(password: "short"))

      assert_response_schema_confirm(422)
      expect(error_pairs).to contain_exactly([ "password", "too_short" ])
    end

    it "同時に同じメールアドレスで登録され、DBの一意制約で弾かれても422（taken）を返し、認証セッションを作らない" do
      # 一意性のバリデーションを通過した後、INSERTの時点で別のリクエストに先を越された状況
      allow_any_instance_of(User).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)

      expect { sign_up(valid_params) }.not_to change(AuthSession, :count)

      assert_schema_conform(422)
      expect(error_pairs).to contain_exactly([ "email", "taken" ])
    end

    it "パスワードが#{User::PASSWORD_MAX_BYTES}バイトを超えれば422（too_long）を返す" do
      sign_up(valid_params.merge(password: "あ" * 25))

      assert_schema_conform(422)
      expect(error_pairs).to contain_exactly([ "password", "too_long" ])
    end

    it "パスワードが無ければ422（blank）だけを返す" do
      sign_up(valid_params.except(:password))

      assert_response_schema_confirm(422)
      expect(error_pairs).to contain_exactly([ "password", "blank" ])
    end

    it "メールアドレスが無ければ422（blank）を返す" do
      sign_up(valid_params.except(:email))

      assert_response_schema_confirm(422)
      expect(error_pairs).to contain_exactly([ "email", "blank" ])
    end

    it "ニックネームが無ければ422（blank）を返す" do
      sign_up(valid_params.except(:nickname))

      assert_response_schema_confirm(422)
      expect(error_pairs).to contain_exactly([ "nickname", "blank" ])
    end
  end
end
