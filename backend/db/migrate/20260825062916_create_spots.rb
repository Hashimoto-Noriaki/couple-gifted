class CreateSpots < ActiveRecord::Migration[8.1]
  def change
    create_table :spots, id: :string do |t|
      t.string :name, null: false
      t.string :area_id, null: false
      t.string :category_id, null: false
      t.decimal :lat, precision: 9, scale: 6
      t.decimal :lng, precision: 9, scale: 6
      t.string :address, null: false
      # published / unpublished（doc/er-and-db-design.md）。削除はせず、
      # レビューが付いている場合はunpublishedに切り替える運用
      t.integer :status, null: false, default: 0
      t.integer :reviews_count, null: false, default: 0
      t.decimal :rating_average, precision: 3, scale: 2

      t.timestamps
    end

    add_foreign_key :spots, :areas
    add_foreign_key :spots, :categories
    # doc/er-and-db-design.md「インデックス」：(area_id, category_id, status) は一覧の絞り込みに使う
    add_index :spots, [ :area_id, :category_id, :status ]
  end
end
