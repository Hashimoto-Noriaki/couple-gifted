class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def render_problem(status:, type:, title:)
    render(
      json: ProblemSerializer.new(
        type: type,
        title: title,
        status: Rack::Utils::SYMBOL_TO_STATUS_CODE.fetch(status),
        request_id: request.request_id
      ).as_json,
      status: status,
      # RFC 9457のメディア型。application/jsonではない（doc/api-design.md「設計上の判断 4」）
      content_type: "application/problem+json"
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
