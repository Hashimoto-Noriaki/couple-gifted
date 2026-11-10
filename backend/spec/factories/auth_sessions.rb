FactoryBot.define do
  # リフレッシュトークンはAuthSessionの作成時に自動で発行される（平文はrefresh_tokenで1度だけ読める）
  factory :auth_session do
    user
  end
end
