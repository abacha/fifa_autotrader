# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_04_211752) do

  create_table "matched_trades", force: :cascade do |t|
    t.string "buy_trade_id"
    t.string "sell_trade_id"
    t.integer "profit"
    t.integer "duration"
    t.integer "timestamp"
    t.string "player_name"
    t.date "date"
  end

  create_table "notification_subscribers", force: :cascade do |t|
    t.string "endpoint"
    t.string "p256dh"
    t.string "auth"
  end

  create_table "player_snipes", force: :cascade do |t|
    t.string "name"
    t.string "fullname"
    t.string "rarity"
    t.string "quality"
    t.integer "max_bid"
    t.integer "bought", default: 0
    t.integer "rating"
    t.string "position"
  end

  create_table "player_trades", force: :cascade do |t|
    t.string "name"
    t.string "fullname"
    t.integer "max_bid"
    t.integer "sell_value"
    t.integer "status", default: 0
    t.string "futbin_id"
    t.string "resource_id"
    t.string "rarity"
    t.string "quality"
    t.integer "rating"
    t.string "position"
  end

  create_table "settings", force: :cascade do |t|
    t.string "key"
    t.text "value"
    t.integer "secure", default: 0, null: false
  end

  create_table "trades", force: :cascade do |t|
    t.datetime "timestamp"
    t.string "kind"
    t.string "player_name"
    t.integer "start_price"
    t.integer "sold_for"
    t.integer "buy_now"
    t.integer "matched", default: 0
    t.date "date"
  end

end
