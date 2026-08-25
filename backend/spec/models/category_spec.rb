require "rails_helper"

RSpec.describe Category, type: :model do
  it { is_expected.to have_many(:spots) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:position) }

  describe ".ordered" do
    it "position昇順で返す" do
      third = create(:category, position: 3)
      first = create(:category, position: 1)
      second = create(:category, position: 2)

      expect(Category.ordered).to eq([ first, second, third ])
    end
  end
end
