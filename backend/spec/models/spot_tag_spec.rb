require 'rails_helper'

RSpec.describe SpotTag, type: :model do
  describe 'アソシエーション' do
    it { should belong_to(:spot) }
    it { should belong_to(:tag) }
  end
end
