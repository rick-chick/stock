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

ActiveRecord::Schema.define(:version => 20141222004854) do

  create_table "code_dates", :id => false, :force => true do |t|
    t.integer  "id",      :limit => 8, :null => false
    t.string   "code",    :limit => 8
    t.string   "date",    :limit => 8
    t.datetime "updated"
  end

  add_index "code_dates", ["code", "date"], :name => "code_date_index", :unique => true

  create_table "code_times", :id => false, :force => true do |t|
    t.integer  "id",      :limit => 8, :null => false
    t.string   "code",    :limit => 8
    t.string   "date",    :limit => 8
    t.string   "time",    :limit => 4
    t.datetime "updated"
  end

  add_index "code_times", ["code", "date", "time"], :name => "code_time_index", :unique => true

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

end
