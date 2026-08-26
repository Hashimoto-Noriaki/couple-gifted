# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_25_062916) do
  create_table "areas", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "parent_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_areas_on_parent_id"
  end

  create_table "categories", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  create_table "spots", id: :string, force: :cascade do |t|
    t.string "address", null: false
    t.string "area_id", null: false
    t.string "category_id", null: false
    t.datetime "created_at", null: false
    t.decimal "lat", precision: 9, scale: 6
    t.decimal "lng", precision: 9, scale: 6
    t.string "name", null: false
    t.decimal "rating_average", precision: 3, scale: 2
    t.integer "reviews_count", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["area_id", "category_id", "status"], name: "index_spots_on_area_id_and_category_id_and_status"
  end

  add_foreign_key "areas", "areas", column: "parent_id"
  add_foreign_key "spots", "areas"
  add_foreign_key "spots", "categories"
end
