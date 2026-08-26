# doc/api/openapi.yaml（SSoT）のパスを一箇所にまとめる。
# committee-rails（spec/rails_helper.rbのcommittee_options）とSwagger UI
# （app/controllers/api_docs_controller.rb）の両方から参照するため、
# 全環境で読み込む（development限定にしない）。
# doc/ はコンテナに /doc としてマウントされている（docker-compose.yml参照。/rails からは見えない）
Rails.application.config.x.openapi_schema_path = Rails.root.join("..", "doc", "api", "openapi.yaml")
