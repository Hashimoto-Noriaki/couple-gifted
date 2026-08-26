FactoryBot.define do
  factory :spot do
    sequence(:name) { |n| "スポット#{n}" }
    area
    category
    address { "東京都渋谷区代官山町1-1" }
    lat { 35.649_128 }
    lng { 139.702_552 }
    status { :published }
    reviews_count { 0 }
    rating_average { nil }
  end
end
