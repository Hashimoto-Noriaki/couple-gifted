FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    nickname { 'test_user' }
    gender { 'male' }
    relationship_status { 'dating' }
  end
end
