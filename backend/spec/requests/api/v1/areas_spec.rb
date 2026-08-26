require "rails_helper"

RSpec.describe "GET /api/v1/areas", type: :request do
  it "position昇順でエリア一覧を返す" do
    third = create(:area, position: 3)
    first = create(:area, position: 1)
    second = create(:area, position: 2)

    get "/api/v1/areas"

    assert_schema_conform(200)
    expect(response.parsed_body["areas"].pluck("id")).to eq([ first.id, second.id, third.id ])
  end

  it "親子構造（parent_id）を含めて返す" do
    shibuya = create(:area, name: "渋谷エリア", parent: nil)
    daikanyama = create(:area, name: "代官山", parent: shibuya)

    get "/api/v1/areas"

    assert_schema_conform(200)
    body = response.parsed_body["areas"]
    expect(body.find { |a| a["id"] == shibuya.id }["parent_id"]).to be_nil
    expect(body.find { |a| a["id"] == daikanyama.id }["parent_id"]).to eq(shibuya.id)
  end

  it "エリアが無ければ空配列を返す" do
    get "/api/v1/areas"

    assert_schema_conform(200)
    expect(response.parsed_body["areas"]).to eq([])
  end
end
