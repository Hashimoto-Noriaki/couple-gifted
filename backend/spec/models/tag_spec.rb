require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'バリデーション' do
    subject { build(:tag) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'アソシエーション' do
    it { should have_many(:spot_tags) }
    it { should have_many(:spots).through(:spot_tags) }
  end
end
