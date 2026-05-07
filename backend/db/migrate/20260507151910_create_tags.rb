class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :spot_tags, [:spot_id, :tag_id], unique: true
  end
end
