class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  # 会員限定のアクションに付ける。Authorization: Bearer <アクセストークン> から本人を確かめる
  # （doc/api/openapi.yaml「bearerAuth」、決定事項ログ #30）。停止・退会済みの会員は認証済みとして扱わない
  def authenticate!
    auth_session = AuthSession.find_by_access_token(bearer_token)
    @current_auth_session = auth_session if auth_session&.user&.active?
    render_unauthenticated unless current_auth_session
  end

  attr_reader :current_auth_session

  def current_user
    current_auth_session&.user
  end

  def bearer_token
    # 認証方式名は大文字小文字を区別しない（RFC 7235）
    request.authorization.to_s[/\ABearer\s+(\S+)\z/i, 1]
  end

  # トークンが無い・誤り・期限切れ・失効済みのどれでも同じ応答にする
  def render_unauthenticated
    response.headers["WWW-Authenticate"] = "Bearer"
    render_problem(
      status: :unauthorized,
      type: "#{ProblemSerializer::BASE_URI}/unauthenticated",
      title: "ログインが必要です"
    )
  end

  def render_problem(status:, type:, title:, errors: nil)
    render(
      json: ProblemSerializer.new(
        type: type,
        title: title,
        status: Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch(status),
        request_id: request.request_id,
        errors: errors
      ).as_json,
      status: status,
      # RFC 9457のメディア型。application/jsonではない（doc/api-design.md「設計上の判断 4」）
      content_type: "application/problem+json"
    )
  end

  # 表示する文言はクライアントがfield・codeから組み立てる（APIは文言を返さない。doc/api/openapi.yaml「ValidationProblem」）
  def render_validation_problem(errors)
    render_problem(
      status: :unprocessable_content,
      type: "#{ProblemSerializer::BASE_URI}/validation-failed",
      title: "入力内容に誤りがあります",
      errors: errors.map { |error| { field: error.attribute.to_s, code: error.type.to_s } }
    )
  end

  def render_not_found
    render_problem(
      status: :not_found,
      type: "#{ProblemSerializer::BASE_URI}/not-found",
      title: "対象が見つかりません"
    )
  end
end
