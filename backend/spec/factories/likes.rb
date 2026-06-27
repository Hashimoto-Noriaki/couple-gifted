FactoryBot.define do
  factory :like do
    association :user
    association :spot_review
  end
end
