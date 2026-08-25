require "rails_helper"

RSpec.describe "GET /api/v1/spots", type: :request do
  let(:area) { create(:area) }
  let(:other_area) { create(:area) }
  let(:category) { create(:category) }
  let(:other_category) { create(:category) }

  it "公開中のスポットを返す" do
    spot = create(:spot, area: area, category: category, status: :published)

    get "/api/v1/spots"

    assert_schema_conform(200)
    body = response.parsed_body
    expect(body["spots"].pluck("id")).to eq([ spot.id ])
    expect(body["next_cursor"]).to be_nil
  end

  it "非公開（unpublished）のスポットは返さない（doc/domain-model.md：ゲストが検索・閲覧できるのは公開中のみ）" do
    create(:spot, status: :unpublished)

    get "/api/v1/spots"

    assert_schema_conform(200)
    expect(response.parsed_body["spots"]).to eq([])
  end

  it "area_idで絞り込む（探す軸）" do
    matching = create(:spot, area: area)
    create(:spot, area: other_area)

    get "/api/v1/spots", params: { area_id: area.id }

    assert_schema_conform(200)
    expect(response.parsed_body["spots"].pluck("id")).to eq([ matching.id ])
  end

  it "category_idで絞り込む（探す軸）" do
    matching = create(:spot, category: category)
    create(:spot, category: other_category)

    get "/api/v1/spots", params: { category_id: category.id }

    assert_schema_conform(200)
    expect(response.parsed_body["spots"].pluck("id")).to eq([ matching.id ])
  end

  it "各スポットの評価・件数を返す" do
    spot = create(:spot, rating_average: 4.5, reviews_count: 3)

    get "/api/v1/spots"

    assert_schema_conform(200)
    returned = response.parsed_body["spots"].first
    expect(returned["average_rating"]).to eq(4.5)
    expect(returned["reviews_count"]).to eq(3)
  end

  describe "カーソルページネーション" do
    it "limit件を超える場合、next_cursorを返す" do
      create_list(:spot, 3)

      get "/api/v1/spots", params: { limit: 2 }

      assert_schema_conform(200)
      body = response.parsed_body
      expect(body["spots"].size).to eq(2)
      expect(body["next_cursor"]).to be_present
    end

    it "cursorを渡すと続きから返す（新しい順・重複や取りこぼしが無い）" do
      spots = create_list(:spot, 3) { |spot, i| spot.update!(created_at: i.days.ago) }

      get "/api/v1/spots", params: { limit: 2 }
      first_page_ids = response.parsed_body["spots"].pluck("id")
      next_cursor = response.parsed_body["next_cursor"]

      get "/api/v1/spots", params: { limit: 2, cursor: next_cursor }
      assert_schema_conform(200)
      body = response.parsed_body

      expect(first_page_ids).to eq(spots.first(2).map(&:id))
      expect(body["spots"].pluck("id")).to eq([ spots.last.id ])
      expect(body["next_cursor"]).to be_nil
      expect(body["spots"].pluck("id") & first_page_ids).to eq([])
    end

    it "壊れたcursorは400（Problem Details）を返す" do
      get "/api/v1/spots", params: { cursor: "not-a-valid-cursor" }

      assert_schema_conform(400)
      body = response.parsed_body
      expect(body["status"]).to eq(400)
      expect(body["title"]).to be_present
    end

    it "cursorが配列（cursor[]=a&cursor[]=b）で送られても500ではなく400を返す" do
      # openapi.yaml上はcursorをstringとして定義しているが、committee-railsはRequest Specの
      # アサーションとしてのみ組み込まれており、実行時ミドルウェアとしては動いていない
      # （.claude/rules/backend.md）。よってスキーマに反する入力も実際にはControllerまで届くため、
      # ここではassert_request_schema_confirmを経由しないassert_response_schema_confirmで、
      # 実際のレスポンスが期待通り400（Problem Details）であることだけを確認する
      get "/api/v1/spots", params: { cursor: [ "a", "b" ] }

      assert_response_schema_confirm(400)
    end

    it "limitが配列（limit[]=1&limit[]=2）で送られても500ではなく400を返す" do
      get "/api/v1/spots", params: { limit: [ "1", "2" ] }

      assert_response_schema_confirm(400)
    end
  end
end
