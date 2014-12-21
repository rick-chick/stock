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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20141220074213) do

  create_table "a_distributions", :id => false, :force => true do |t|
    t.integer "length", :null => false
    t.float   "a",      :null => false
    t.float   "na",     :null => false
    t.float   "p"
  end

  create_table "code_dates", :id => false, :force => true do |t|
    t.integer  "id",      :limit => 8, :null => false
    t.string   "code",    :limit => 8
    t.string   "date",    :limit => 8
    t.datetime "updated"
  end

  add_index "code_dates", ["code", "date"], :name => "code_date_index", :unique => true

  create_table "codes", :id => false, :force => true do |t|
    t.string "code", :limit => 10, :null => false
  end

  create_table "correrations", :id => false, :force => true do |t|
    t.string "code1",     :limit => 10, :null => false
    t.string "date1",     :limit => 8,  :null => false
    t.string "code2",     :limit => 10, :null => false
    t.string "date2",     :limit => 8,  :null => false
    t.float  "length_10"
    t.float  "length_20"
    t.float  "length_40"
  end

  create_table "dates", :id => false, :force => true do |t|
    t.string "date", :limit => 8, :null => false
  end

  create_table "indexies", :id => false, :force => true do |t|
    t.string  "code",   :limit => 4,  :null => false
    t.string  "date",   :limit => 8,  :null => false
    t.string  "name",   :limit => 10, :null => false
    t.integer "length",               :null => false
    t.float   "a"
  end

  create_table "old_stocks", :id => false, :force => true do |t|
    t.string  "code",     :limit => 10,                                :null => false
    t.string  "date",     :limit => 8,                                 :null => false
    t.decimal "open",                   :precision => 10, :scale => 2
    t.decimal "high",                   :precision => 10, :scale => 2
    t.decimal "low",                    :precision => 10, :scale => 2
    t.decimal "close",                  :precision => 10, :scale => 2
    t.decimal "adjusted",               :precision => 10, :scale => 2
    t.integer "volume",   :limit => 8
  end

  create_table "pair_orders", :id => false, :force => true do |t|
    t.string  "code1",        :limit => 10,                :null => false
    t.string  "code2",        :limit => 10,                :null => false
    t.string  "date",         :limit => 8,                 :null => false
    t.integer "condition_id",                              :null => false
    t.integer "weight1",                    :default => 1
    t.integer "weight2",                    :default => 1
    t.string  "sold",         :limit => 8
    t.string  "bought",       :limit => 8
  end

  create_table "pairs", :id => false, :force => true do |t|
    t.integer "id",    :limit => 8,  :null => false
    t.string  "code1", :limit => 10, :null => false
    t.string  "code2", :limit => 10, :null => false
    t.string  "date1", :limit => 8,  :null => false
    t.string  "date2", :limit => 8,  :null => false
  end

  create_table "probability", :id => false, :force => true do |t|
    t.string  "code",   :limit => 4, :null => false
    t.string  "date",   :limit => 8, :null => false
    t.integer "length",              :null => false
    t.float   "a"
  end

  create_table "splits", :id => false, :force => true do |t|
    t.integer  "id",      :limit => 8, :null => false
    t.float    "before"
    t.float    "after"
    t.datetime "updated"
  end

  create_table "stocks", :force => true do |t|
    t.float    "open"
    t.float    "high"
    t.float    "low"
    t.float    "close"
    t.float    "adjusted"
    t.integer  "volume",   :limit => 8
    t.datetime "updated"
  end

  create_table "temp_correrations", :id => false, :force => true do |t|
    t.string "code1",     :limit => 10
    t.string "code2",     :limit => 10
    t.string "date1",     :limit => 8
    t.string "date2",     :limit => 8
    t.float  "length_10"
    t.float  "length_20"
    t.float  "length_40"
  end

end
