require "rails_helper"

# /api-docs はdevelopment限定（config/routes.rb参照）。テストはtest環境で動くため、
# development環境を模してルーティングを再読み込みしてから検証する。
RSpec.describe "GET /api-docs/openapi.yaml", type: :request do
  before do
    allow(Rails).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new("development"))
    Rails.application.reload_routes!
  end

  after do
    # 先にstubを外してから戻さないと、development扱いのままreloadしてルートが残ってしまう
    allow(Rails).to receive(:env).and_call_original
    Rails.application.reload_routes!
  end

  it "doc/api/openapi.yamlをそのまま返す" do
    get "/api-docs/openapi.yaml"

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("application/yaml")
    # send_fileはASCII-8BITで返すため、バイト単位で比較する
    expect(response.body).to eq(File.binread(Rails.application.config.x.openapi_schema_path))
  end
end

RSpec.describe "GET /api-docs/openapi.yaml（development以外）", type: :request do
  it "test環境ではルーティングされない" do
    get "/api-docs/openapi.yaml"

    expect(response).to have_http_status(:not_found)
  end
end
