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

ActiveRecord::Schema.define(version: 20170210183758) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "user_id"
    t.decimal  "price",      default: 0.0
    t.integer  "quantity",   default: 0
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "frames", force: :cascade do |t|
    t.string "name"
  end

  create_table "item_messages", force: :cascade do |t|
    t.text     "message"
    t.integer  "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "item_messages", ["item_id"], name: "index_item_messages_on_item_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "height"
    t.integer  "width"
    t.string   "image"
    t.decimal  "price",               precision: 30, scale: 2
    t.integer  "quantity",                                     default: 1
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.decimal  "depth"
    t.string   "border"
    t.integer  "cart_id"
    t.integer  "order_id"
    t.string   "size"
    t.boolean  "art_filter"
    t.string   "somatic_url"
    t.string   "art_image"
    t.string   "art_model_id"
    t.integer  "frame_id"
    t.decimal  "mat"
    t.string   "image_tmp"
    t.string   "image_overview_tmp"
    t.hstore   "image_tmp_paths",                              default: {}
    t.hstore   "art_image_tmp_paths",                          default: {}
    t.decimal  "image_h_w_ratio"
    t.integer  "clone_of"
    t.boolean  "received",                                     default: false
    t.integer  "rate"
  end

  add_index "items", ["cart_id"], name: "index_items_on_cart_id", using: :btree
  add_index "items", ["frame_id"], name: "index_items_on_frame_id", using: :btree
  add_index "items", ["order_id"], name: "index_items_on_order_id", using: :btree
  add_index "items", ["product_id"], name: "index_items_on_product_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.string   "shipping_full_name"
    t.string   "shipping_address_1"
    t.string   "shipping_address_2"
    t.string   "shipping_city"
    t.string   "shipping_zip"
    t.string   "shipping_phone"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "user_id"
    t.decimal  "before_price"
    t.decimal  "shipping_price"
    t.decimal  "tax_price"
    t.decimal  "total_price"
    t.integer  "state_id"
    t.integer  "country_id"
    t.string   "number"
    t.string   "status",             default: "new"
    t.hstore   "oem_info",           default: {}
    t.integer  "processing_status"
  end

  add_index "orders", ["country_id"], name: "index_orders_on_country_id", using: :btree
  add_index "orders", ["state_id"], name: "index_orders_on_state_id", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shipping_addresses", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.integer  "state_id"
    t.integer  "country_id"
    t.string   "zip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "shipping_addresses", ["country_id"], name: "index_shipping_addresses_on_country_id", using: :btree
  add_index "shipping_addresses", ["state_id"], name: "index_shipping_addresses_on_state_id", using: :btree
  add_index "shipping_addresses", ["user_id"], name: "index_shipping_addresses_on_user_id", using: :btree

  create_table "states", force: :cascade do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "carts", "users"
  add_foreign_key "item_messages", "items"
  add_foreign_key "items", "carts"
  add_foreign_key "items", "frames"
  add_foreign_key "items", "orders"
  add_foreign_key "items", "products"
  add_foreign_key "orders", "countries"
  add_foreign_key "orders", "states"
  add_foreign_key "orders", "users"
  add_foreign_key "shipping_addresses", "countries"
  add_foreign_key "shipping_addresses", "states"
  add_foreign_key "shipping_addresses", "users"
end
