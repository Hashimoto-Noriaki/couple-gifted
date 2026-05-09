FactoryBot.define do
  factory :spot_review do
    association :user
    association :spot
    rating { 4 }
    body { "とても良いスポットでした。" }
    relationship_status_at_visit { "dating" }
  end
end
