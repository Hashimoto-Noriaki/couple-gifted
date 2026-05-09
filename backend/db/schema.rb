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

ActiveRecord::Schema[8.1].define(version: 2026_05_07_152022) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "spot_reviews", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "rating"
    t.string "relationship_status_at_visit"
    t.bigint "spot_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["spot_id"], name: "index_spot_reviews_on_spot_id"
    t.index ["user_id"], name: "index_spot_reviews_on_user_id"
  end

  create_table "spot_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "spot_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["spot_id", "tag_id"], name: "index_spot_tags_on_spot_id_and_tag_id", unique: true
    t.index ["spot_id"], name: "index_spot_tags_on_spot_id"
    t.index ["tag_id"], name: "index_spot_tags_on_tag_id"
  end

  create_table "spots", force: :cascade do |t|
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.string "google_place_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["google_place_id"], name: "index_spots_on_google_place_id", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "allow_password_change", default: false
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "gender"
    t.string "image"
    t.string "name"
    t.string "nickname"
    t.string "provider", default: "email", null: false
    t.string "relationship_status"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.json "tokens"
    t.string "uid", default: "", null: false
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "spot_reviews", "spots"
  add_foreign_key "spot_reviews", "users"
  add_foreign_key "spot_tags", "spots"
  add_foreign_key "spot_tags", "tags"
end
