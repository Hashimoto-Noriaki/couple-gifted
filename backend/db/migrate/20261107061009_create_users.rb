class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :string do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :nickname, null: false
      # 年代（doc/er-and-db-design.md）。null = 未設定
      t.integer :age_band
      # 居住エリア。null = 未設定
      t.references :area, type: :string, foreign_key: true
      t.boolean :has_children, null: false, default: false
      # 関係ステージ（doc/ubiquitous-language.md）。null = 未設定
      t.integer :relationship_stage
      # active / suspended / withdrawn
      t.integer :status, null: false, default: 0
      t.datetime :withdrawn_at

      t.timestamps
    end
    # 停止済み・退会済みの会員と同じメールアドレスでも登録させない（doc/use-cases.md「新規登録する」）。
    # アプリ側のチェックだけだと同時実行で破れるため、DBでも守る
    add_index :users, :email, unique: true
  end
end
