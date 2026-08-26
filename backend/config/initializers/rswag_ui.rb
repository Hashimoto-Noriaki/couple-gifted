# Swagger UI（development限定。config/routes.rb参照）
# doc/api/openapi.yaml がSSoT。config/routes.rbのapi_docs#openapiがそのまま返す
if Rails.env.development?
  Rswag::Ui.configure do |c|
    c.openapi_endpoint "/api-docs/openapi.yaml", "CoupleGifted API V1"
  end
end
