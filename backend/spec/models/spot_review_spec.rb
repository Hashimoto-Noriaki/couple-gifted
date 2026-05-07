require 'rails_helper'

RSpec.describe SpotReview, type: :model do
  describe 'バリデーション' do
    subject { build(:spot_review) }

    it { should validate_presence_of(:rating) }
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:relationship_status_at_visit) }
  end

  describe 'アソシエーション' do
    it { should belong_to(:user) }
    it { should belong_to(:spot) }
  end
end
