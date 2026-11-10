class CreateAuthSessions < ActiveRecord::Migration[8.1]
  # 認証セッション。ログインのたびに1行作る（doc/er-and-db-design.md「auth_sessions」、決定事項ログ #30）
  def change
    create_table :auth_sessions, id: :string do |t|
      t.references :user, type: :string, null: false, foreign_key: true
      # リフレッシュトークンのSHA-256ダイジェスト。平文は保存しない
      t.string :refresh_token_digest, null: false
      t.datetime :refresh_token_expires_at, null: false
      # 1つ前（入れ替え済み）のリフレッシュトークンのダイジェスト。再び使われたら盗用とみなしてセッションを消す
      t.string :previous_refresh_token_digest

      t.timestamps
    end
    add_index :auth_sessions, :refresh_token_digest, unique: true
    add_index :auth_sessions, :previous_refresh_token_digest
  end
end
