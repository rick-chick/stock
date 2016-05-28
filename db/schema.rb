# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160528064708) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "boards", primary_key: "code", force: :cascade do |t|
    t.float   "price"
    t.float   "sell"
    t.float   "buy"
    t.float   "sell_volume"
    t.float   "buy_volume"
    t.float   "open"
    t.string  "open_time",   limit: 5
    t.float   "high"
    t.string  "high_time",   limit: 5
    t.float   "low"
    t.string  "low_time",    limit: 5
    t.string  "time",        limit: 5
    t.float   "volume"
    t.float   "tick"
    t.float   "diff"
    t.float   "rate"
    t.boolean "closed"
  end

  create_table "code_dates", id: :bigserial, force: :cascade do |t|
    t.string   "code",         limit: 8
    t.string   "date",         limit: 8
    t.datetime "updated"
    t.integer  "stock_key_id", limit: 8
  end

  add_index "code_dates", ["code", "date"], name: "code_date_index", unique: true, using: :btree

  create_table "code_times", id: :bigserial, force: :cascade do |t|
    t.string   "code",         limit: 8
    t.string   "date",         limit: 8
    t.string   "time",         limit: 4
    t.datetime "updated"
    t.integer  "stock_key_id", limit: 8
  end

  add_index "code_times", ["code", "date", "time"], name: "code_time_index", unique: true, using: :btree

  create_table "orders", id: :bigserial, force: :cascade do |t|
    t.string   "code",       limit: 8
    t.datetime "date"
    t.integer  "no"
    t.boolean  "force"
    t.float    "price"
    t.integer  "volume",     limit: 8
    t.string   "trade_kbn",  limit: 1
    t.datetime "updated"
    t.string   "opperation", limit: 1
  end

  add_index "orders", ["code", "date", "no"], name: "order_table_index", unique: true, using: :btree

  create_table "pair_times", id: :bigserial, force: :cascade do |t|
    t.string   "code1",        limit: 8
    t.string   "code2",        limit: 8
    t.datetime "time"
    t.datetime "updated"
    t.integer  "stock_key_id", limit: 8
  end

  add_index "pair_times", ["code1", "code2", "time"], name: "pair_time_index", unique: true, using: :btree

  create_table "splits", id: :bigserial, force: :cascade do |t|
    t.float    "before"
    t.float    "after"
    t.datetime "updated"
  end

  create_table "stock_keys", id: :bigserial, force: :cascade do |t|
    t.datetime "updated"
  end

  create_table "stocks", id: :bigserial, force: :cascade do |t|
    t.float    "open"
    t.float    "high"
    t.float    "low"
    t.float    "close"
    t.float    "adjusted"
    t.integer  "volume",       limit: 8
    t.datetime "updated"
    t.integer  "stock_key_id", limit: 8
  end

  add_foreign_key "code_dates", "stock_keys", name: "fk_code_date_stock_key"
  add_foreign_key "code_times", "stock_keys", name: "fk_code_time_stock_key"
  add_foreign_key "pair_times", "stock_keys", name: "fk_pair_time_stock_key"
  add_foreign_key "splits", "code_dates", column: "id", name: "splits_id_fkey"
  add_foreign_key "stocks", "stock_keys", name: "fk_stock_stock_key"
end
