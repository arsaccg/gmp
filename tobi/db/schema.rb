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

ActiveRecord::Schema.define(version: 20140516222318) do

  create_table "advances", force: true do |t|
    t.string   "advance_type"
    t.integer  "advance_number"
    t.float    "advance_direct_cost_percent"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  create_table "budgets", force: true do |t|
    t.string   "cod_budget"
    t.string   "description"
    t.integer  "term"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "level"
    t.string   "subbudget_code"
    t.integer  "deleted"
    t.string   "type_of_budget"
    t.float    "utility"
    t.float    "general_expenses"
  end

  create_table "charges", force: true do |t|
    t.integer  "invoice_id"
    t.float    "amount"
    t.date     "charge_date"
    t.float    "payment_amount"
    t.string   "financial_agent_client"
    t.string   "financial_agent_destiny"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cost_centers", force: true do |t|
    t.string   "name"
    t.float    "total_amount"
    t.float    "direct_cost_amount"
    t.float    "general_cost_amount"
    t.float    "utility_amount"
    t.float    "advance_payment_percent"
    t.float    "coaching_granted_percent"
    t.float    "igv"
    t.integer  "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
  end

  create_table "extensionscontrols", force: true do |t|
    t.string   "description"
    t.string   "motive"
    t.string   "status"
    t.float    "requested_deadline"
    t.float    "approved_deadline"
    t.float    "requested_mgg"
    t.string   "resolution"
    t.string   "observation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.string   "files"
    t.float    "approved_mgg"
  end

  create_table "input_units", force: true do |t|
    t.integer  "unit_id"
    t.integer  "input_id"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inputbybudgetanditems", force: true do |t|
    t.string   "coditem"
    t.string   "ownitem"
    t.string   "cod_input"
    t.float    "quantity",       limit: 10
    t.float    "price",          limit: 10
    t.float    "aprox"
    t.string   "order"
    t.float    "measured",       limit: 10
    t.string   "input"
    t.integer  "budget_id"
    t.string   "subbudget_code"
    t.integer  "item_id"
    t.integer  "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "budget_code"
    t.string   "owneritem"
    t.string   "unit"
  end

  add_index "inputbybudgetanditems", ["cod_input"], name: "cod_input_index", using: :btree
  add_index "inputbybudgetanditems", ["cod_input"], name: "inputbybudgetanditems_codinput", using: :btree
  add_index "inputbybudgetanditems", ["id"], name: "inputbybudgets_id", using: :btree
  add_index "inputbybudgetanditems", ["item_id"], name: "inputbybudgets_item_id", using: :btree
  add_index "inputbybudgetanditems", ["order"], name: "inputbybudgets_order", using: :btree

  create_table "inputcategories", force: true do |t|
    t.integer  "category_id"
    t.integer  "level_n"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inputcategories", ["category_id"], name: "category_id", unique: true, using: :btree
  add_index "inputcategories", ["category_id"], name: "inputcategories_index", using: :btree

  create_table "inputs", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", force: true do |t|
    t.integer  "valorization_id"
    t.float    "amount"
    t.date     "issue_date"
    t.date     "filing_date"
    t.string   "status"
    t.string   "credit_note"
    t.string   "observations"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_number"
  end

  create_table "itembybudgets", force: true do |t|
    t.string   "item_code"
    t.string   "order"
    t.float    "measured",        limit: 10
    t.float    "price",           limit: 10
    t.float    "partial"
    t.string   "subbudget_code"
    t.string   "budget_code"
    t.integer  "budget_id"
    t.integer  "item_id"
    t.integer  "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "subbudgetdetail"
    t.string   "owneritem"
  end

  add_index "itembybudgets", ["item_id"], name: "itembybudges_item_id", using: :btree

  create_table "itembywbses", force: true do |t|
    t.string   "wbscode"
    t.integer  "itembywbs_id"
    t.string   "coditem"
    t.string   "order_budget"
    t.string   "partial"
    t.string   "subbudget_code"
    t.float    "price"
    t.string   "budget_code"
    t.integer  "budget_id"
    t.integer  "item_id"
    t.string   "status_flag"
    t.integer  "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "wbsitem_id"
    t.float    "measured",        limit: 10
    t.float    "project_id"
    t.string   "subbudgetdetail"
    t.integer  "itembybudget_id"
  end

  create_table "items", force: true do |t|
    t.string   "item_code"
    t.integer  "project_code"
    t.string   "wbs_parent_code"
    t.string   "budget_code"
    t.string   "description"
    t.string   "own_code"
    t.integer  "level"
    t.string   "unity_code"
    t.integer  "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  create_table "managers", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 3
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dni"
    t.string   "kind"
  end

  add_index "managers", ["authentication_token"], name: "index_managers_on_authentication_token", unique: true, using: :btree
  add_index "managers", ["email"], name: "index_managers_on_email", unique: true, using: :btree
  add_index "managers", ["reset_password_token"], name: "index_managers_on_reset_password_token", unique: true, using: :btree

  create_table "projects", force: true do |t|
    t.string   "custom_code"
    t.string   "name",                     default: "Untitled", null: false
    t.float    "total_amount"
    t.float    "direct_cost_amount"
    t.float    "general_cost_amount"
    t.float    "utility_amount"
    t.float    "advance_payment_percent"
    t.float    "coaching_granted_percent"
    t.integer  "status_flag"
    t.integer  "manager_id"
    t.string   "period"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "deleted",                  default: 0
    t.float    "igv"
    t.string   "owner"
    t.integer  "company_id"
  end

  create_table "units", force: true do |t|
    t.string   "symbol"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "valorization_caches", force: true do |t|
    t.string   "description"
    t.string   "und"
    t.float    "unit_price"
    t.float    "contract_price"
    t.float    "sumarized_before"
    t.float    "sumarized_actual"
    t.float    "credit_valorization"
    t.float    "advance"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "budget_id"
    t.integer  "order_number"
  end

  create_table "valorizationitems", force: true do |t|
    t.integer  "valorization_id"
    t.integer  "itembybudget_id"
    t.float    "actual_measured"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "valorizations", force: true do |t|
    t.string   "month"
    t.string   "name"
    t.string   "status"
    t.integer  "budget_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "general_expenses"
    t.float    "utility"
    t.float    "readjustment"
    t.float    "no_direct_r"
    t.float    "no_materials_r"
    t.float    "direct_advance"
    t.float    "advance_of_materials"
    t.date     "valorization_date"
  end

  create_table "wbsitems", force: true do |t|
    t.string   "codewbs"
    t.string   "name"
    t.string   "description"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "predecessors"
    t.string   "fase_id"
    t.string   "fase"
    t.integer  "cost_center_id"
  end

end
