FactoryBot.define do
  factory :spot_review do
    user { nil }
    spot { nil }
    rating { 1 }
    body { "MyText" }
    relationship_status_at_visit { "MyString" }
  end
end
