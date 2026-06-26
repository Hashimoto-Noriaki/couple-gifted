require 'rails_helper'

RSpec.describe SpotReview, type: :model do
  describe 'バリデーション' do
    subject { build(:spot_review) }

    it { should validate_presence_of(:rating) }
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:relationship_status_at_visit) }

    it { should validate_numericality_of(:rating).only_integer.is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5) }
  end

  describe 'アソシエーション' do
    it { should belong_to(:user) }
    it { should belong_to(:spot) }
  end

  describe '#owned_by?' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:review) { create(:spot_review, user: owner) }

    it 'オーナーに対してtrueを返す' do
      expect(review.owned_by?(owner)).to be true
    end

    it '他のユーザーに対してfalseを返す' do
      expect(review.owned_by?(other_user)).to be false
    end
  end
end
