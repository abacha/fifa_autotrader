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

ActiveRecord::Schema.define(version: 2021_01_31_161414) do

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "fullname"
    t.integer "max_bid"
    t.integer "sell_value"
    t.integer "status"
    t.string "futbin_id"
    t.string "resource_id"
  end

  create_table "trades", force: :cascade do |t|
    t.datetime "timestamp"
    t.string "kind"
    t.string "player_name"
    t.integer "start_price"
    t.integer "sold_for"
    t.integer "buy_now"
  end

end
