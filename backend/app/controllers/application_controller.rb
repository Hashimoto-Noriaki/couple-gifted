class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

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
