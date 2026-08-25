FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "カテゴリ#{n}" }
    sequence(:position)
  end
end
