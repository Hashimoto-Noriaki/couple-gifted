class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # doc/er-and-db-design.md の通り主キーはuuid。SQLiteにネイティブなuuid型は無いため、
  # DB側のデフォルト（Postgresのgen_random_uuid()相当）は使わず、アプリ側で生成する
  # （doc/api/openapi.yaml「idの型について」参照）。
  before_create { self.id ||= SecureRandom.uuid }
end
