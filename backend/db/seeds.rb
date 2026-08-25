# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# issue #49 動作確認用のseedデータ。
# カテゴリの分類軸はdoc/ubiquitous-language.md「スポットの分類軸が未定義」の通りまだ未確定のため、
# ここに挙げるのは動作確認のための例であって、正式なカテゴリ一覧ではない。
# エリアはdoc/er-and-db-design.md「エリアの粒度」の例（渋谷エリアの子に代官山・恵比寿）に合わせている。

shibuya = Area.find_or_create_by!(name: "渋谷エリア") { |area| area.position = 1 }
daikanyama = Area.find_or_create_by!(name: "代官山", parent: shibuya) { |area| area.position = 1 }
ebisu = Area.find_or_create_by!(name: "恵比寿", parent: shibuya) { |area| area.position = 2 }

cafe = Category.find_or_create_by!(name: "カフェ") { |category| category.position = 1 }
restaurant = Category.find_or_create_by!(name: "レストラン") { |category| category.position = 2 }
park = Category.find_or_create_by!(name: "公園") { |category| category.position = 3 }

[
  { name: "代官山ガーデンカフェ", area: daikanyama, category: cafe, address: "東京都渋谷区代官山町1-1",
    lat: 35.649_128, lng: 139.702_552, reviews_count: 12, rating_average: 4.3 },
  { name: "恵比寿ダイニング", area: ebisu, category: restaurant, address: "東京都渋谷区恵比寿1-1-1",
    lat: 35.646_631, lng: 139.710_105, reviews_count: 8, rating_average: 4.0 },
  { name: "代官山パークサイド", area: daikanyama, category: park, address: "東京都渋谷区代官山町2-2",
    lat: 35.650_2, lng: 139.703_1, reviews_count: 0, rating_average: nil }
].each do |attrs|
  Spot.find_or_create_by!(name: attrs[:name]) do |spot|
    spot.assign_attributes(attrs.except(:name).merge(status: :published))
  end
end

puts "Seeded: #{Area.count} areas, #{Category.count} categories, #{Spot.count} spots"
