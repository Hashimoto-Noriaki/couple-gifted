require "rails_helper"

RSpec.describe Spot, type: :model do
  it { is_expected.to belong_to(:area) }
  it { is_expected.to belong_to(:category) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:address) }
  it { is_expected.to define_enum_for(:status).with_values(published: 0, unpublished: 1) }

  describe "id" do
    it "アプリ側でuuidを生成する（SQLiteにネイティブなuuid型は無いため）" do
      spot = create(:spot)

      expect(spot.id).to match(/\A[0-9a-f-]{36}\z/)
    end
  end

  describe "lat/lng" do
    it "null許容（doc/er-and-db-design.md）" do
      spot = build(:spot, lat: nil, lng: nil)

      expect(spot).to be_valid
    end

    it "数値でなければ無効" do
      spot = build(:spot, lat: "not-a-number")

      expect(spot).not_to be_valid
    end
  end

  describe "reviews_count" do
    it "負の値は無効" do
      spot = build(:spot, reviews_count: -1)

      expect(spot).not_to be_valid
    end
  end

  describe "rating_average" do
    it "レビューが無ければnullを許容する" do
      spot = build(:spot, rating_average: nil)

      expect(spot).to be_valid
    end

    it "1〜5の範囲外なら無効" do
      expect(build(:spot, rating_average: 0.9)).not_to be_valid
      expect(build(:spot, rating_average: 5.1)).not_to be_valid
    end
  end

  describe ".published" do
    it "status: publishedの行だけを返す" do
      published_spot = create(:spot, status: :published)
      create(:spot, status: :unpublished)

      expect(Spot.published).to contain_exactly(published_spot)
    end
  end

  describe "カーソルページネーション" do
    describe ".ordered_for_listing" do
      it "created_at降順で返す（同時刻はid降順でタイブレークする）" do
        older = create(:spot, created_at: 2.days.ago)
        newer = create(:spot, created_at: 1.day.ago)

        expect(Spot.ordered_for_listing).to eq([ newer, older ])
      end
    end

    describe ".encode_cursor / .decode_cursor" do
      it "スポットからカーソルを作り、同じ(created_at, id)に復元できる" do
        spot = create(:spot)

        cursor = Spot.encode_cursor(spot)
        created_at, id = Spot.decode_cursor(cursor)

        expect(id).to eq(spot.id)
        expect(created_at).to be_within(1.second).of(spot.created_at)
      end

      it "空のcursorはnilを返す（1ページ目）" do
        expect(Spot.decode_cursor(nil)).to be_nil
        expect(Spot.decode_cursor("")).to be_nil
      end

      it "壊れたcursorはArgumentErrorを送出する" do
        expect { Spot.decode_cursor("not-a-valid-cursor!!") }.to raise_error(ArgumentError)
      end

      it "文字列以外のcursor（例：cursor[]=a&cursor[]=bで配列になった場合）はArgumentErrorを送出する" do
        expect { Spot.decode_cursor([ "a", "b" ]) }.to raise_error(ArgumentError)
      end

      it "セパレータ「|」が無いcursorはArgumentErrorを送出する（idがnilのまま素通りしない）" do
        cursor = Base64.urlsafe_encode64(Time.current.iso8601(6))

        expect { Spot.decode_cursor(cursor) }.to raise_error(ArgumentError)
      end
    end

    describe ".after_cursor" do
      it "cursorより後（created_atが古い方）だけを返す" do
        oldest = create(:spot, created_at: 3.days.ago)
        middle = create(:spot, created_at: 2.days.ago)
        newest = create(:spot, created_at: 1.day.ago)

        created_at, id = Spot.decode_cursor(Spot.encode_cursor(middle))

        expect(Spot.after_cursor(created_at, id).ordered_for_listing).to eq([ oldest ])
        expect(Spot.after_cursor(created_at, id).ordered_for_listing).not_to include(newest, middle)
      end
    end
  end
end
