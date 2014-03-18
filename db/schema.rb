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

<<<<<<< HEAD
ActiveRecord::Schema.define(version: 20140313203418) do
=======
ActiveRecord::Schema.define(version: 20140318200845) do
>>>>>>> 8e58e5a3bfc0a1b5f9d7eb4ea178adf2990baa6b

  create_table "article_unit_of_measurements", force: true do |t|
    t.integer  "article_id"
    t.integer  "unit_of_measurement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code_article_unit"
  end

  create_table "articles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "code"
    t.integer  "category_id"
    t.integer  "type_of_article_id"
  end

  create_table "categories", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "center_of_attentions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation"
  end

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "ruc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cost_centers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.integer  "company_id"
  end

  create_table "delivery_order_details", force: true do |t|
    t.integer  "phase_id"
    t.integer  "sector_id"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_of_measurement_id"
    t.integer  "amount"
    t.text     "description"
    t.integer  "delivery_order_id"
    t.date     "scheduled_date"
    t.integer  "center_of_attention_id"
  end

  create_table "delivery_orders", force: true do |t|
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.date     "date_of_issue"
    t.date     "scheduled"
    t.text     "description"
    t.integer  "cost_center_id"
  end

  create_table "phases", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category"
    t.string   "code"
  end

  create_table "purchase_order_details", force: true do |t|
    t.integer  "delivery_order_detail_id"
    t.float    "unit_price"
    t.boolean  "igv"
    t.float    "unit_price_igv"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_orders", force: true do |t|
    t.string   "state"
    t.date     "date_of_issue"
    t.date     "expiration_date"
    t.date     "delivery_date"
    t.boolean  "retention"
    t.integer  "money_id"
    t.integer  "method_of_payment_id"
    t.integer  "supplier_id"
    t.integer  "user_id"
    t.integer  "cost_center_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sectors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
  end

  create_table "state_per_order_details", force: true do |t|
    t.integer  "delivery_order_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "subcategories", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
  end

  create_table "type_of_articles", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "unit_of_measurements", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "symbol"
    t.string   "code"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "surname"
    t.date     "date_of_birth"
    t.string   "avatar"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "roles_mask",             default: 1
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
