class SpotReviewSerializer
  include JSONAPI::Serializer

  attributes :rating, :body, :relationship_status_at_visit, :created_at

  attribute :user_nickname do |object|
    object.user.nickname
  end
end
