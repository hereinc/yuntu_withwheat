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

ActiveRecord::Schema.define(version: 1) do

  create_table "member_feedbacks", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.datetime "record_time"
    t.string   "memo",          limit: 255
    t.string   "feedback_type", limit: 255
    t.datetime "create_time"
    t.string   "user_name",     limit: 255
    t.string   "src_sys",       limit: 255
    t.datetime "yt_datetime"
  end

  add_index "member_feedbacks", ["yt_datetime"], name: "index_member_feedbacks_on_yt_datetime", using: :btree

  create_table "members", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.string   "age",             limit: 255
    t.string   "member_name",     limit: 255
    t.datetime "create_time"
    t.datetime "record_time"
    t.string   "regist_shopname", limit: 255
    t.string   "__sex__option__", limit: 255
    t.string   "sex",             limit: 255
    t.string   "src_sys",         limit: 255
    t.datetime "yt_datetime"
  end

  add_index "members", ["user_id"], name: "index_members_on_user_id", unique: true, using: :btree
  add_index "members", ["yt_datetime"], name: "index_members_on_yt_datetime", using: :btree

  create_table "order_items", force: :cascade do |t|
    t.datetime "delivery_time"
    t.datetime "record_time"
    t.integer  "meal_count",                  limit: 4
    t.string   "order_status",                limit: 255
    t.integer  "product_id",                  limit: 4
    t.integer  "user_id",                     limit: 4
    t.datetime "create_time"
    t.string   "product_name",                limit: 255
    t.decimal  "pay_price",                               precision: 21, scale: 6
    t.string   "address",                     limit: 255
    t.datetime "pay_time"
    t.string   "order_id",                    limit: 255
    t.string   "member_name",                 limit: 255
    t.string   "__delivery_status__option__", limit: 255
    t.string   "delivery_status",             limit: 255
    t.string   "__order_status__option__",    limit: 255
    t.string   "src_sys",                     limit: 255
    t.datetime "yt_datetime"
  end

  add_index "order_items", ["yt_datetime"], name: "index_order_items_on_yt_datetime", using: :btree

  create_table "products", force: :cascade do |t|
    t.integer  "product_id",    limit: 4
    t.decimal  "current_price",             precision: 21, scale: 6
    t.string   "product_name",  limit: 255
    t.datetime "create_time"
    t.string   "product_code",  limit: 255
    t.decimal  "pref_price",                precision: 21, scale: 6
    t.string   "src_sys",       limit: 255
    t.datetime "yt_datetime"
  end

  add_index "products", ["product_id"], name: "index_products_on_product_id", unique: true, using: :btree
  add_index "products", ["yt_datetime"], name: "index_products_on_yt_datetime", using: :btree

end
