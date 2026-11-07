# 会員の情報。password_digest・status等は返さない（doc/api/openapi.yaml「User」）
class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
    {
      id: user.id,
      email: user.email,
      nickname: user.nickname,
      age_band: user.age_band,
      area_id: user.area_id,
      has_children: user.has_children,
      relationship_stage: user.relationship_stage
    }
  end

  private

  attr_reader :user
end
