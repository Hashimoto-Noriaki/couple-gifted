# Swagger UI（rswag-ui）が読み込む doc/api/openapi.yaml を生ファイルのまま返すだけの薄いController。
# doc/api/openapi.yaml がSSoT（.claude/rules/backend.md）。development限定（config/routes.rb参照）
class ApiDocsController < ApplicationController
  def openapi
    send_file Rails.application.config.x.openapi_schema_path, type: "application/yaml", disposition: "inline"
  end
end
