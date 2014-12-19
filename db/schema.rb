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

ActiveRecord::Schema.define(:version => 20141218083905) do

  create_table "splits", :id => false, :force => true do |t|
    t.string "code",   :limit => 8
    t.string "date",   :limit => 8
    t.float  "before"
    t.float  "after"
  end

  create_table "stocks", :id => false, :force => true do |t|
    t.string  "code",     :limit => 8, :null => false
    t.string  "date",     :limit => 8, :null => false
    t.float   "open"
    t.float   "high"
    t.float   "low"
    t.float   "close"
    t.float   "adjusted"
    t.integer "volume",   :limit => 8
  end

end
