FactoryBot.define do
  factory :area do
    sequence(:name) { |n| "エリア#{n}" }
    sequence(:position)
    parent { nil }
  end
end
