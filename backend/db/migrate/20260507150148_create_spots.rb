class CreateSpots < ActiveRecord::Migration[8.1]
  def change
    create_table :spots do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :google_place_id, null: false

      t.timestamps
    end

    add_index :spots, :google_place_id, unique: true
  end
end
