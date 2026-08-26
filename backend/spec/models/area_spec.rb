require "rails_helper"

RSpec.describe Area, type: :model do
  it { is_expected.to belong_to(:parent).class_name("Area").optional }
  it { is_expected.to have_many(:children).class_name("Area") }
  it { is_expected.to have_many(:spots) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:position) }

  describe "親子構造" do
    it "親エリアを持てる（例：渋谷エリアの子に代官山）" do
      shibuya = create(:area, name: "渋谷エリア")
      daikanyama = create(:area, name: "代官山", parent: shibuya)

      expect(daikanyama.parent).to eq(shibuya)
      expect(shibuya.children).to contain_exactly(daikanyama)
    end

    it "最上位エリアはparentを持たない" do
      shibuya = create(:area, name: "渋谷エリア", parent: nil)

      expect(shibuya.parent).to be_nil
    end
  end

  describe ".ordered" do
    it "position昇順で返す" do
      third = create(:area, position: 3)
      first = create(:area, position: 1)
      second = create(:area, position: 2)

      expect(Area.ordered).to eq([ first, second, third ])
    end
  end
end
