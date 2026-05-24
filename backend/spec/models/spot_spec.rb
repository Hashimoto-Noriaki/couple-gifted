require 'rails_helper'

RSpec.describe Spot, type: :model do
  describe 'バリデーション' do
    subject { build(:spot) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:google_place_id) }
    it { should validate_uniqueness_of(:google_place_id) }
  end

  describe 'アソシエーション' do
    it { should have_many(:spot_reviews) }
    it { should have_many(:spot_tags) }
    it { should have_many(:tags).through(:spot_tags) }
  end
end
