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

ActiveRecord::Schema.define(version: 20151112152819) do

  create_table "physiqual_tokens", force: :cascade do |t|
    t.string   "token"
    t.string   "refresh_token"
    t.datetime "valid_until"
    t.integer  "physiqual_user_id", null: false
    t.string   "type",              null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "physiqual_tokens", ["physiqual_user_id"], name: "index_physiqual_tokens_on_physiqual_user_id"
  add_index "physiqual_tokens", ["type", "physiqual_user_id"], name: "index_physiqual_tokens_on_type_and_physiqual_user_id", unique: true

  create_table "physiqual_users", force: :cascade do |t|
    t.string   "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "physiqual_users", ["user_id"], name: "index_physiqual_users_on_user_id", unique: true

end
