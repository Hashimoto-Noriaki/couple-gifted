require 'rails_helper'

RSpec.describe Like, type: :model do
  describe 'アソシエーション' do
    it { should belong_to(:user) }
    it { should belong_to(:spot_review) }
  end

  describe 'バリデーション' do
    subject { build(:like) }

    it { should validate_uniqueness_of(:user_id).scoped_to(:spot_review_id) }
  end
end
