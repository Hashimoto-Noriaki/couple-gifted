# RFC 9457 (Problem Details) 形式でエラーを返す。doc/api-design.md「設計上の判断 4」参照。
# Controllerで直接ハッシュを組み立てないためのSerializer層（doc/domain-model.mdの通り、
# 具体的な手段〈jbuilder等〉は未決定のためgemは追加せず、素のRubyクラスで経由させる）。
class ProblemSerializer
  BASE_URI = "https://couplegifted.example/errors".freeze

  def initialize(type:, title:, status:, request_id: nil)
    @type = type
    @title = title
    @status = status
    @request_id = request_id
  end

  def as_json(*)
    {
      type: type,
      title: title,
      status: status,
      request_id: request_id
    }.compact
  end

  private

  attr_reader :type, :title, :status, :request_id
end
