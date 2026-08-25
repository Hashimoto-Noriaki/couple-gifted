require "rails_helper"

RSpec.describe "GET /api/v1/categories", type: :request do
  it "position昇順でカテゴリ一覧を返す" do
    third = create(:category, position: 3)
    first = create(:category, position: 1)
    second = create(:category, position: 2)

    get "/api/v1/categories"

    assert_schema_conform(200)
    expect(response.parsed_body["categories"].pluck("id")).to eq([ first.id, second.id, third.id ])
  end

  it "カテゴリが無ければ空配列を返す" do
    get "/api/v1/categories"

    assert_schema_conform(200)
    expect(response.parsed_body["categories"]).to eq([])
  end
end
