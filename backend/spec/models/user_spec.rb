require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    subject { build(:user) }

    it { should validate_presence_of(:nickname) }
    it { should validate_presence_of(:gender) }
    it { should validate_inclusion_of(:gender).in_array(%w[male female other]) }
    it { should validate_presence_of(:relationship_status) }
    it { should validate_inclusion_of(:relationship_status).in_array(%w[dating married]) }
  end
end
