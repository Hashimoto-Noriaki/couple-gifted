FactoryBot.define do
  factory :spot do
    sequence(:name) { |n| "テストスポット#{n}" }
    address { "東京都渋谷区渋谷1-1-1" }
    sequence(:google_place_id) { |n| "ChIJtest#{n}" }
  end
end
