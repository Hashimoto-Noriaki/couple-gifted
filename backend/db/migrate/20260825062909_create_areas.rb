class CreateAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :areas, id: :string do |t|
      t.string :name, null: false
      # 親エリア（doc/er-and-db-design.md「エリアの粒度」：上位に「渋谷エリア」、その子に「代官山」等）。
      # 最上位エリアは null
      t.string :parent_id
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :areas, :parent_id
    add_foreign_key :areas, :areas, column: :parent_id
  end
end
