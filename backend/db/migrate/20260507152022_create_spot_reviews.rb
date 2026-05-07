class CreateSpotReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :spot_reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :spot, null: false, foreign_key: true
      t.integer :rating
      t.text :body
      t.string :relationship_status_at_visit

      t.timestamps
    end
  end
end
