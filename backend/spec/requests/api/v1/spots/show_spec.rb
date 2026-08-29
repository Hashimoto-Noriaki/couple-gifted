require "rails_helper"

RSpec.describe "GET /api/v1/spots/:id", type: :request do
  it "スポットの詳細を返す" do
    spot = create(:spot, status: :published, rating_average: 4.2, reviews_count: 5)

    get "/api/v1/spots/#{spot.id}"

    assert_schema_conform(200)
    body = response.parsed_body
    expect(body["id"]).to eq(spot.id)
    expect(body["name"]).to eq(spot.name)
    expect(body["average_rating"]).to eq(4.2)
    expect(body["reviews_count"]).to eq(5)
  end

  it "住所を返す（行くかどうかを判断するための情報）" do
    spot = create(:spot, address: "東京都渋谷区代官山町1-1")

    get "/api/v1/spots/#{spot.id}"

    assert_schema_conform(200)
    expect(response.parsed_body["address"]).to eq("東京都渋谷区代官山町1-1")
  end

  it "未認証（ゲスト）では常にsaved: falseを返す（doc/api/openapi.yaml：認証導入前は本人を判定できない）" do
    spot = create(:spot)

    get "/api/v1/spots/#{spot.id}"

    assert_schema_conform(200)
    expect(response.parsed_body["saved"]).to eq(false)
  end

  it "非公開（unpublished）のスポットは404を返す（doc/domain-model.md：ゲストが閲覧できるのは公開中のみ）" do
    spot = create(:spot, status: :unpublished)

    get "/api/v1/spots/#{spot.id}"

    assert_schema_conform(404)
    expect(response.media_type).to eq("application/problem+json")
  end

  it "存在しないidは404（Problem Details）を返す" do
    get "/api/v1/spots/#{SecureRandom.uuid}"

    assert_schema_conform(404)
    expect(response.media_type).to eq("application/problem+json")
    body = response.parsed_body
    expect(body["status"]).to eq(404)
    expect(body["title"]).to be_present
  end
end
