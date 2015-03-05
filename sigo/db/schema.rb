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

ActiveRecord::Schema.define(version: 20150304210201) do

  create_table "TmpRepInv", id: false, force: true do |t|
    t.integer "input"
    t.integer "warehouse_id"
    t.string  "warehouse_name", limit: 256
    t.integer "year"
    t.integer "period"
    t.date    "issue_date"
    t.integer "article_id"
    t.string  "article_code",   limit: 12
    t.string  "article_name",   limit: 256
    t.string  "article_symbol", limit: 256
    t.decimal "amount",                     precision: 18, scale: 4
    t.decimal "unit_cost",                  precision: 18, scale: 4
  end

  create_table "TmpRepInvGroup", id: false, force: true do |t|
    t.integer "warehouse_id"
    t.string  "warehouse_name", limit: 256
    t.integer "year"
    t.integer "period"
    t.date    "issue_date"
    t.integer "article_id"
    t.string  "article_code",   limit: 12
    t.string  "article_name",   limit: 256
    t.string  "article_symbol", limit: 256
    t.decimal "i_amount",                   precision: 18, scale: 4
    t.decimal "i_unit_cost",                precision: 18, scale: 4
    t.decimal "i_total_cost",               precision: 18, scale: 4
    t.decimal "o_amount",                   precision: 18, scale: 4
    t.decimal "o_unit_cost",                precision: 18, scale: 4
    t.decimal "o_total_cost",               precision: 18, scale: 4
  end

  create_table "account_accountants", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "advances", force: true do |t|
    t.string   "advance_type"
    t.integer  "advance_number"
    t.float    "advance_direct_cost_percent"
    t.float    "amount"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "payment_date"
  end

  create_table "afp_details", force: true do |t|
    t.integer  "afp_id"
    t.float    "mixed"
    t.date     "date_entry"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "contribution_fp"
    t.float    "insurance_premium"
    t.float    "top"
    t.float    "c_variable"
  end

  add_index "afp_details", ["afp_id"], name: "afp_id", using: :btree

  create_table "afps", force: true do |t|
    t.string   "enterprise"
    t.float    "mixed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
    t.float    "contribution_fp"
    t.float    "insurance_premium"
    t.float    "top"
    t.float    "c_variable"
    t.string   "type_of_afp"
  end

  create_table "amortization_by_valorizations", force: true do |t|
    t.integer  "code"
    t.string   "kind"
    t.integer  "valorization_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "arbitration_documents", force: true do |t|
    t.string   "attachment"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.string   "attachment_file_size"
    t.datetime "attachment_update_at"
    t.integer  "work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "arbitration_documents", ["work_id"], name: "work_id", using: :btree

  create_table "archeologies", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "archeologies", ["cost_center_id"], name: "cost_center_id", using: :btree

  create_table "articles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "code"
    t.integer  "type_of_article_id"
    t.integer  "unit_of_measurement_id"
    t.string   "category_id"
  end

  add_index "articles", ["category_id"], name: "category_id", using: :btree
  add_index "articles", ["type_of_article_id"], name: "type_of_article_id", using: :btree
  add_index "articles", ["unit_of_measurement_id"], name: "unit_of_measurement_id", using: :btree

  create_table "articles_from_cost_center_1", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  add_index "articles_from_cost_center_1", ["article_id"], name: "article_id", using: :btree
  add_index "articles_from_cost_center_1", ["budget_id"], name: "budget_id", using: :btree
  add_index "articles_from_cost_center_1", ["category_id"], name: "category_id", using: :btree
  add_index "articles_from_cost_center_1", ["cost_center_id"], name: "cost_center_id", using: :btree
  add_index "articles_from_cost_center_1", ["input_by_budget_and_items_id"], name: "input_by_budget_and_items_id", using: :btree
  add_index "articles_from_cost_center_1", ["type_of_article_id"], name: "type_of_article_id", using: :btree
  add_index "articles_from_cost_center_1", ["unit_of_measurement_id"], name: "unit_of_measurement_id", using: :btree

  create_table "articles_from_cost_center_10", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_11", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_12", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_13", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_14", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_15", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_16", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_17", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_18", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_19", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_2", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_20", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_21", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_22", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_23", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_24", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_25", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_26", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_27", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_3", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_4", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_5", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_6", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_7", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_8", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "articles_from_cost_center_9", force: true do |t|
    t.integer "article_id"
    t.string  "code"
    t.integer "type_of_article_id"
    t.integer "category_id"
    t.string  "name"
    t.string  "description"
    t.integer "unit_of_measurement_id"
    t.integer "cost_center_id"
    t.integer "input_by_budget_and_items_id"
    t.integer "budget_id"
  end

  create_table "banks", force: true do |t|
    t.string   "business_name"
    t.string   "ruc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "money_id"
    t.string   "account_type"
    t.string   "account_number"
    t.string   "account_detraction"
    t.string   "cci"
  end

  create_table "bond_letter_details", force: true do |t|
    t.string   "code"
    t.date     "issu_date"
    t.datetime "expiration_date"
    t.float    "amount"
    t.float    "issuance_cost"
    t.float    "retention_amount"
    t.float    "rate"
    t.integer  "bond_letter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "retention_percentage"
  end

  create_table "bond_letters", force: true do |t|
    t.integer  "cost_center_id"
    t.integer  "issuer_entity_id"
    t.integer  "receptor_entity_id"
    t.integer  "concept"
    t.integer  "advance_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "book_works", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_of_book_work_id"
    t.date     "date"
  end

  create_table "budgets", force: true do |t|
    t.string   "cod_budget"
    t.string   "description"
    t.integer  "term"
    t.integer  "cost_center_id"
    t.integer  "level"
    t.string   "subbudget_code"
    t.integer  "deleted"
    t.string   "type_of_budget"
    t.float    "utility"
    t.float    "general_expenses"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "category_of_workers", force: true do |t|
    t.float    "normal_price"
    t.float    "he_60_price"
    t.float    "he_100_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "article_id"
    t.string   "name"
    t.integer  "category_id"
    t.date     "change_date"
    t.integer  "cost_center_id"
  end

  add_index "category_of_workers", ["article_id"], name: "article_id", using: :btree

  create_table "category_of_workers_concepts", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_of_worker_id"
    t.integer  "concept_id"
    t.string   "amount"
    t.string   "type_concept"
    t.string   "concept_code"
  end

  create_table "center_of_attentions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation"
    t.integer  "cost_center_id"
  end

  add_index "center_of_attentions", ["cost_center_id"], name: "cost_center_id", using: :btree

  create_table "certificates", force: true do |t|
    t.integer  "professional_id"
    t.integer  "work_id"
    t.integer  "charge_id"
    t.string   "contractor"
    t.date     "start_date"
    t.date     "finish_date"
    t.integer  "other_work_id"
    t.string   "certificate"
    t.string   "certificate_file_name"
    t.string   "certificate_content_type"
    t.integer  "certificate_file_size"
    t.datetime "certificate_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "other"
    t.string   "other_file_name"
    t.string   "other_content_type"
    t.integer  "other_file_size"
    t.datetime "other_updated_at"
    t.integer  "num_days"
  end

  add_index "certificates", ["charge_id"], name: "charge_id", using: :btree
  add_index "certificates", ["other_work_id"], name: "other_work_id", using: :btree
  add_index "certificates", ["professional_id"], name: "professional_id", using: :btree
  add_index "certificates", ["work_id"], name: "work_id", using: :btree

  create_table "certificates_professionals", force: true do |t|
    t.integer  "certificate_id"
    t.integer  "professional_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "certificates_professionals", ["certificate_id"], name: "certificate_id", using: :btree
  add_index "certificates_professionals", ["professional_id"], name: "professional_id", using: :btree

  create_table "charges", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "amount"
    t.date     "charge_date"
    t.float    "payment_amount"
    t.string   "financial_agent_client"
    t.string   "financial_agent_destiny"
    t.integer  "invoice_id"
  end

  add_index "charges", ["invoice_id"], name: "invoice_id", using: :btree

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "ruc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "address"
    t.string   "short_name"
  end

  create_table "companies_users", force: true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "companies_users", ["company_id"], name: "company_id", using: :btree
  add_index "companies_users", ["user_id"], name: "user_id", using: :btree

  create_table "components", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "specialty"
  end

  create_table "components_other_works", force: true do |t|
    t.integer  "other_work_id"
    t.integer  "component_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "components_other_works", ["component_id"], name: "component_id", using: :btree
  add_index "components_other_works", ["other_work_id"], name: "other_work_id", using: :btree

  create_table "components_works", force: true do |t|
    t.integer  "work_id"
    t.integer  "component_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "components_works", ["work_id", "component_id"], name: "index_components_works_on_work_id_and_component_id", using: :btree
  add_index "components_works", ["work_id"], name: "work_id", using: :btree

  create_table "concept_details", force: true do |t|
    t.integer  "concept_id"
    t.integer  "subconcept_id"
    t.string   "category"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "concept_details", ["concept_id"], name: "concept_id", using: :btree
  add_index "concept_details", ["subconcept_id"], name: "subconcept_id", using: :btree

  create_table "concept_valorizations", force: true do |t|
    t.integer  "concept_id"
    t.date     "date_week"
    t.integer  "cost_center_id"
    t.integer  "concept_reference_id"
    t.string   "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "formula"
    t.integer  "type_worker"
  end

  create_table "concepts", force: true do |t|
    t.string   "name"
    t.float    "percentage"
    t.float    "amount"
    t.string   "code"
    t.float    "top"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type_obrero"
    t.integer  "status"
    t.string   "type_empleado"
    t.integer  "company_id"
    t.string   "token"
  end

  create_table "concepts_type_of_payslips", force: true do |t|
    t.integer  "concept_id"
    t.integer  "type_of_payslip_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contest_documents", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_of_contest_document_id"
  end

  add_index "contest_documents", ["cost_center_id"], name: "cost_center_id", using: :btree
  add_index "contest_documents", ["type_of_contest_document_id"], name: "type_of_contest_document_id", using: :btree

  create_table "contract_documents", force: true do |t|
    t.string   "attachment"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.string   "attachment_file_size"
    t.datetime "attachment_update_at"
    t.integer  "work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contract_documents", ["work_id"], name: "work_id", using: :btree

  create_table "contract_types", force: true do |t|
    t.string   "description"
    t.string   "shortdescription"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contractual_documents", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_of_contractual_document_id"
  end

  add_index "contractual_documents", ["cost_center_id"], name: "cost_center_id", using: :btree
  add_index "contractual_documents", ["type_of_contractual_document_id"], name: "type_of_contractual_document_id", using: :btree

  create_table "cost_center_details", force: true do |t|
    t.string   "name"
    t.date     "call_date"
    t.integer  "snip_code"
    t.string   "process_number"
    t.date     "good_pro_date"
    t.string   "referential_value"
    t.string   "earned_value"
    t.string   "direct_cost"
    t.string   "general_cost"
    t.string   "utility"
    t.string   "IGV"
    t.date     "contract_sign_date"
    t.string   "contract_number"
    t.date     "land_delivery_date"
    t.date     "direct_advanced_payment_date"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "amazon_tax_condition",           default: "No aplica"
    t.date     "direct_advanced_form_date"
    t.date     "start_date_of_work"
    t.string   "procurement_system"
    t.integer  "execution_term"
    t.string   "supervision"
    t.date     "material_advanced_payment_date"
    t.integer  "entity_id"
    t.string   "district"
    t.string   "province"
    t.string   "department"
  end

  add_index "cost_center_details", ["cost_center_id"], name: "cost_center_id", using: :btree
  add_index "cost_center_details", ["entity_id"], name: "entity_id", using: :btree

  create_table "cost_center_timelines", force: true do |t|
    t.integer "cost_center_id"
    t.date    "date"
    t.integer "year"
    t.integer "period"
    t.integer "week"
    t.integer "day"
  end

  add_index "cost_center_timelines", ["cost_center_id"], name: "cost_center_id", using: :btree
  add_index "cost_center_timelines", ["cost_center_id"], name: "index_cost_center_timelines_on_cost_center_id", using: :btree

  create_table "cost_centers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.integer  "company_id"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "status"
    t.integer  "deleted",              default: 0
    t.binary   "igv",        limit: 1
    t.date     "date_max"
    t.date     "date_min"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "speciality"
    t.boolean  "active"
  end

  add_index "cost_centers", ["company_id"], name: "company_id", using: :btree

  create_table "cost_centers_users", force: true do |t|
    t.integer  "cost_center_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cost_centers_users", ["cost_center_id"], name: "cost_center_id", using: :btree
  add_index "cost_centers_users", ["user_id"], name: "user_id", using: :btree

  create_table "data_summary_accountings", force: true do |t|
    t.integer  "account_accountant_id"
    t.integer  "sub_daily_id"
    t.date     "accounting_date"
    t.float    "amount"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_order_details", force: true do |t|
    t.integer  "phase_id"
    t.integer  "sector_id"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "unit_of_measurement_id"
    t.float    "amount"
    t.text     "description"
    t.integer  "delivery_order_id"
    t.date     "scheduled_date"
    t.integer  "center_of_attention_id"
    t.boolean  "requested"
    t.integer  "lock_version",           default: 0, null: false
  end

  add_index "delivery_order_details", ["article_id"], name: "article_id", using: :btree
  add_index "delivery_order_details", ["center_of_attention_id"], name: "center_of_attention_id", using: :btree
  add_index "delivery_order_details", ["delivery_order_id"], name: "delivery_order_id", using: :btree
  add_index "delivery_order_details", ["phase_id"], name: "phase_id", using: :btree
  add_index "delivery_order_details", ["sector_id"], name: "sector_id", using: :btree
  add_index "delivery_order_details", ["unit_of_measurement_id"], name: "unit_of_measurement_id", using: :btree

  create_table "delivery_orders", force: true do |t|
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.date     "date_of_issue"
    t.date     "scheduled"
    t.text     "description"
    t.integer  "cost_center_id"
    t.integer  "lock_version",   default: 0, null: false
    t.string   "code"
  end

  add_index "delivery_orders", ["cost_center_id"], name: "cost_center_id", using: :btree
  add_index "delivery_orders", ["user_id"], name: "user_id", using: :btree

  create_table "distribution_items", force: true do |t|
    t.integer  "distribution_id"
    t.string   "month"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "distributions", force: true do |t|
    t.string   "code"
    t.string   "description"
    t.string   "und"
    t.float    "measured"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cost_center_id"
    t.integer  "budget_id"
  end

  create_table "diverse_expenses_of_management_details", force: true do |t|
    t.integer  "diverse_expenses_of_management_id"
    t.string   "code"
    t.float    "amount"
    t.date     "delivered_date"
    t.integer  "entity_id"
    t.string   "bill_concept"
    t.string   "bill"
    t.date     "bill_date"
    t.string   "bill_amount"
    t.string   "bill_detraction"
    t.string   "bill_to_account"
    t.string   "igv_commission"
    t.string   "net_return"
    t.string   "balance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "diverse_expenses_of_managements", force: true do |t|
    t.string   "name"
    t.string   "amount"
    t.string   "expenses"
    t.string   "total_delivered"
    t.integer  "cost_center_id"
    t.float    "percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "document_provisions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "status"
    t.integer  "user_inserts_id"
    t.integer  "user_updates_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "preffix"
  end

  create_table "download_softwares", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "file"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_update_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type_of_cost_center"
  end

  create_table "entities", force: true do |t|
    t.string   "name"
    t.string   "paternal_surname"
    t.string   "dni"
    t.string   "ruc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "address"
    t.string   "maternal_surname"
    t.integer  "cost_center_id"
    t.string   "second_name"
    t.date     "date_of_birth"
    t.string   "gender"
    t.string   "city"
    t.string   "province"
    t.string   "department"
    t.string   "alienslicense"
    t.integer  "cost_center_detail_id"
  end

  add_index "entities", ["cost_center_detail_id"], name: "cost_center_detail_id", using: :btree
  add_index "entities", ["cost_center_id"], name: "cost_center_id", using: :btree

  create_table "entities_type_entities", force: true do |t|
    t.integer  "entity_id"
    t.integer  "type_entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entities_type_entities", ["entity_id", "type_entity_id"], name: "index_entities_type_entities_on_entity_id_and_type_entity_id", using: :btree
  add_index "entities_type_entities", ["entity_id"], name: "entity_id", using: :btree
  add_index "entities_type_entities", ["type_entity_id"], name: "type_entity_id", using: :btree

  create_table "entity_banks", force: true do |t|
    t.integer  "entity_id"
    t.integer  "bank_id"
    t.integer  "money_id"
    t.string   "account_type"
    t.string   "account_number"
    t.string   "account_detraction"
    t.string   "cci"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entity_cost_center_details", force: true do |t|
    t.integer  "cost_center_detail_id"
    t.integer  "entity_id"
    t.integer  "participation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entity_cost_center_details", ["cost_center_detail_id"], name: "cost_center_detail_id", using: :btree
  add_index "entity_cost_center_details", ["entity_id"], name: "entity_id", using: :btree

  create_table "environments", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.datetime "document_updated_at"
    t.integer  "document_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "equivalence_of_items", force: true do |t|
    t.integer  "sale_item_by_budget_id"
    t.integer  "target_item_by_budget_id"
    t.float    "percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cost_center_id"
  end

  create_table "exchange_of_rates", force: true do |t|
    t.datetime "day"
    t.integer  "money_id"
    t.decimal  "value",      precision: 15, scale: 5
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exchange_of_rates", ["money_id"], name: "index_exchange_of_rates_on_money_id", using: :btree

  create_table "extensionscontrols", force: true do |t|
    t.string   "description"
    t.string   "motive"
    t.string   "status"
    t.float    "requested_deadline"
    t.float    "approved_deadline"
    t.float    "requested_mgg"
    t.string   "resolution"
    t.string   "observation"
    t.integer  "cost_center_id"
    t.string   "files"
    t.float    "approved_mgg"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
  end

  create_table "extra_calculations", force: true do |t|
    t.string   "concept"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "extra_information_for_payslips", force: true do |t|
    t.integer  "worker_id"
    t.integer  "concept_id"
    t.float    "amount"
    t.string   "week"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "financial_variables", force: true do |t|
    t.string   "name"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flowcharts", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "photo"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "folders", force: true do |t|
    t.integer  "folderfa_id"
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "format_per_documents", force: true do |t|
    t.integer  "document_id"
    t.integer  "format_id"
    t.string   "status"
    t.integer  "user_inserts_id"
    t.integer  "user_updates_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "format_per_documents", ["document_id"], name: "index_format_per_documents_on_document_id", using: :btree
  add_index "format_per_documents", ["format_id"], name: "index_format_per_documents_on_format_id", using: :btree

  create_table "formats", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "status"
    t.integer  "user_inserts_id"
    t.integer  "user_updates_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "formules", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "general_expense_details", force: true do |t|
    t.integer  "general_expense_id"
    t.string   "type_article"
    t.integer  "article_id"
    t.integer  "people"
    t.float    "participation"
    t.float    "time"
    t.string   "parcial"
    t.float    "amount"
    t.string   "cost"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "general_expenses", force: true do |t|
    t.integer  "phase_id"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "total"
    t.string   "code_phase"
  end

  create_table "graphers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "health_centers", force: true do |t|
    t.string   "enterprise"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "holidays", force: true do |t|
    t.date     "date_holiday"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.float    "quantity"
    t.string   "price"
    t.float    "aprox"
    t.string   "order"
    t.float    "measured"
    t.string   "input"
    t.integer  "budget_id"
    t.string   "subbudget_code"
    t.integer  "item_id"
    t.integer  "deleted"
    t.string   "budget_code"
    t.string   "owneritem"
    t.string   "unit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cost_center_id"
    t.integer  "article_id"
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

  create_table "inputs", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "integrated_bases_documents", force: true do |t|
    t.string   "attachment"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.string   "attachment_file_size"
    t.datetime "attachment_update_at"
    t.integer  "work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interest_links", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type_of_cost_center"
  end

  create_table "invoice_documents", force: true do |t|
    t.string   "attachment"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.string   "attachment_file_size"
    t.datetime "attachment_update_at"
    t.integer  "work_id"
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
    t.string   "document_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issued_letters", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.integer  "year"
    t.string   "type_of_doc"
    t.integer  "type_of_issued_letter_id"
    t.date     "date"
  end

  create_table "itembybudgets", force: true do |t|
    t.string   "item_code"
    t.string   "order"
    t.float    "measured"
    t.float    "price"
    t.float    "partial"
    t.string   "subbudget_code"
    t.string   "budget_code"
    t.integer  "budget_id"
    t.integer  "item_id"
    t.integer  "deleted"
    t.string   "title"
    t.string   "subbudgetdetail"
    t.string   "owneritem"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cost_center_id"
    t.float    "percentage",      default: 0.0
    t.string   "unit"
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
    t.integer  "wbsitem_id"
    t.float    "measured"
    t.integer  "cost_center_id"
    t.string   "subbudgetdetail"
    t.integer  "itembybudget_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "land_deliveries", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.integer  "type_of_land_delivery_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "law_and_regulations", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_update_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type_of_cost_center"
  end

  create_table "law_and_regulations_type_of_law_and_regulations", force: true do |t|
    t.integer  "law_and_regulation_id"
    t.integer  "type_of_law_and_regulation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "link_times", force: true do |t|
    t.date     "date"
    t.integer  "year"
    t.integer  "month"
    t.integer  "week"
    t.integer  "day"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "loans", force: true do |t|
    t.string   "person"
    t.date     "loan_date"
    t.string   "loan_type"
    t.float    "amount"
    t.string   "description"
    t.string   "refund_type"
    t.string   "check_number"
    t.date     "check_date"
    t.string   "state"
    t.date     "refund_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cost_center_beneficiary_id"
    t.integer  "cost_center_lender_id"
    t.string   "loan_doc"
    t.string   "loan_doc_file_name"
    t.string   "loan_doc_content_type"
    t.integer  "loan_doc_file_size"
    t.datetime "loan_doc_update_at"
    t.string   "refund_doc"
    t.string   "refund_doc_file_name"
    t.string   "refund_doc_content_type"
    t.integer  "refund_doc_file_size"
    t.datetime "refund_doc_update_at"
  end

  create_table "majors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "professional_id"
  end

  create_table "majors_professionals", force: true do |t|
    t.integer  "major_id"
    t.integer  "professional_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  add_index "managers", ["authentication_token"], name: "index_managers_on_authentication_token", unique: true, using: :btree
  add_index "managers", ["email"], name: "index_managers_on_email", unique: true, using: :btree
  add_index "managers", ["reset_password_token"], name: "index_managers_on_reset_password_token", unique: true, using: :btree

  create_table "measured_by_sectors", force: true do |t|
    t.integer  "item_id"
    t.integer  "sector_id"
    t.float    "measured"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cost_center_id"
    t.integer  "itembybudget_id"
  end

  create_table "method_of_payments", force: true do |t|
    t.string "name"
    t.string "symbol"
  end

  create_table "modification_files", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.integer  "type_of_modification_file_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "money", force: true do |t|
    t.string   "name"
    t.string   "symbol"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "of_companies", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "company_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_of_company_id"
  end

  create_table "order_of_service_details", force: true do |t|
    t.integer  "article_id"
    t.integer  "sector_id"
    t.integer  "phase_id"
    t.integer  "unit_of_measurement_id"
    t.float    "amount"
    t.string   "unit_price"
    t.boolean  "igv"
    t.string   "unit_price_igv"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_of_service_id"
    t.boolean  "received"
    t.string   "unit_price_before_igv"
    t.string   "discount_before"
    t.string   "discount_after"
    t.string   "quantity_igv"
    t.integer  "lock_version",           default: 0, null: false
    t.integer  "working_group_id"
  end

  add_index "order_of_service_details", ["article_id"], name: "article_id", using: :btree
  add_index "order_of_service_details", ["order_of_service_id"], name: "order_of_service_id", using: :btree
  add_index "order_of_service_details", ["phase_id"], name: "phase_id", using: :btree
  add_index "order_of_service_details", ["sector_id"], name: "sector_id", using: :btree
  add_index "order_of_service_details", ["unit_of_measurement_id"], name: "unit_of_measurement_id", using: :btree

  create_table "order_of_services", force: true do |t|
    t.string   "state"
    t.date     "date_of_issue"
    t.text     "description"
    t.integer  "method_of_payment_id"
    t.integer  "entity_id"
    t.integer  "user_id"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "money_id"
    t.float    "exchange_of_rate"
    t.date     "date_of_service"
    t.integer  "lock_version",         default: 0,    null: false
    t.string   "code"
    t.integer  "user_id_historic"
    t.date     "date_of_elimination"
    t.boolean  "status",               default: true, null: false
  end

  add_index "order_of_services", ["cost_center_id"], name: "cost_center_id", using: :btree
  add_index "order_of_services", ["entity_id"], name: "entity_id", using: :btree
  add_index "order_of_services", ["method_of_payment_id"], name: "method_of_payment_id", using: :btree
  add_index "order_of_services", ["money_id"], name: "money_id", using: :btree
  add_index "order_of_services", ["user_id"], name: "user_id", using: :btree

  create_table "order_service_extra_calculations", force: true do |t|
    t.integer  "order_of_service_detail_id"
    t.integer  "extra_calculation_id"
    t.float    "value"
    t.string   "apply"
    t.string   "operation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "lock_version",               default: 0, null: false
  end

  add_index "order_service_extra_calculations", ["extra_calculation_id"], name: "extra_calculation_id", using: :btree
  add_index "order_service_extra_calculations", ["order_of_service_detail_id"], name: "order_of_service_detail_id", using: :btree

  create_table "other_works", force: true do |t|
    t.string   "name"
    t.date     "start"
    t.date     "end"
    t.integer  "components"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "specialty"
    t.integer  "certificate_id"
    t.string   "entity"
    t.string   "contractor"
  end

  create_table "part_of_equipment_details", force: true do |t|
    t.integer  "working_group_id"
    t.integer  "phase_id"
    t.float    "effective_hours"
    t.string   "unit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "part_of_equipment_id"
    t.integer  "sector_id"
    t.float    "fuel"
    t.integer  "lock_version",         default: 0, null: false
  end

  add_index "part_of_equipment_details", ["part_of_equipment_id"], name: "part_of_equipment_id", using: :btree
  add_index "part_of_equipment_details", ["phase_id"], name: "phase_id", using: :btree
  add_index "part_of_equipment_details", ["sector_id"], name: "sector_id", using: :btree
  add_index "part_of_equipment_details", ["working_group_id"], name: "working_group_id", using: :btree

  create_table "part_of_equipments", force: true do |t|
    t.string   "code"
    t.integer  "subcontract_equipment_id"
    t.integer  "equipment_id"
    t.integer  "worker_id"
    t.string   "initial_km"
    t.string   "final_km"
    t.string   "dif"
    t.integer  "h_stand_by"
    t.integer  "h_maintenance"
    t.float    "fuel_amount"
    t.integer  "subcategory_id"
    t.date     "date"
    t.float    "total_hours"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "block"
    t.integer  "cost_center_id"
    t.integer  "lock_version",             default: 0, null: false
  end

  add_index "part_of_equipments", ["cost_center_id"], name: "cost_center_id", using: :btree
  add_index "part_of_equipments", ["equipment_id"], name: "equipment_id", using: :btree
  add_index "part_of_equipments", ["subcategory_id"], name: "subcategory_id", using: :btree
  add_index "part_of_equipments", ["subcontract_equipment_id"], name: "subcontract_equipment_id", using: :btree
  add_index "part_of_equipments", ["worker_id"], name: "worker_id", using: :btree

  create_table "part_people", force: true do |t|
    t.integer  "working_group_id"
    t.string   "number_part"
    t.date     "date_of_creation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "block"
    t.integer  "blockweekly"
    t.integer  "cost_center_id"
    t.integer  "lock_version",     default: 0, null: false
    t.integer  "payroll_used",     default: 0, null: false
  end

  add_index "part_people", ["cost_center_id"], name: "cost_center_id", using: :btree
  add_index "part_people", ["working_group_id"], name: "working_group_id", using: :btree

  create_table "part_person_details", force: true do |t|
    t.integer  "worker_id"
    t.integer  "phase_id"
    t.float    "normal_hours"
    t.float    "he_60"
    t.float    "he_100"
    t.float    "total_hours"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "part_person_id"
    t.integer  "sector_id"
    t.integer  "lock_version",   default: 0, null: false
  end

  add_index "part_person_details", ["phase_id"], name: "phase_id", using: :btree
  add_index "part_person_details", ["sector_id"], name: "sector_id", using: :btree
  add_index "part_person_details", ["worker_id"], name: "worker_id", using: :btree

  create_table "part_work_details", force: true do |t|
    t.integer  "part_work_id"
    t.integer  "itembybudget_id"
    t.float    "bill_of_quantitties"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",        default: 0, null: false
  end

  add_index "part_work_details", ["itembybudget_id"], name: "article_id", using: :btree
  add_index "part_work_details", ["part_work_id"], name: "part_work_id", using: :btree

  create_table "part_worker_details", force: true do |t|
    t.integer  "worker_id"
    t.integer  "phase_id"
    t.integer  "sector_id"
    t.string   "assistance"
    t.string   "reason_of_lack"
    t.integer  "working_group_id"
    t.integer  "cost_center_id"
    t.integer  "part_worker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",     default: 0, null: false
    t.string   "he_25"
    t.string   "he_35"
  end

  add_index "part_worker_details", ["cost_center_id"], name: "cost_center_id", using: :btree
  add_index "part_worker_details", ["part_worker_id"], name: "part_worker_id", using: :btree
  add_index "part_worker_details", ["phase_id"], name: "phase_id", using: :btree
  add_index "part_worker_details", ["sector_id"], name: "sector_id", using: :btree
  add_index "part_worker_details", ["worker_id"], name: "worker_id", using: :btree
  add_index "part_worker_details", ["working_group_id"], name: "working_group_id", using: :btree

  create_table "part_workers", force: true do |t|
    t.string   "number_part"
    t.date     "date_of_creation"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",     default: 0,     null: false
    t.integer  "payroll_used",     default: 0,     null: false
    t.boolean  "blockweekly",      default: false, null: false
    t.boolean  "blockpayslip",     default: false, null: false
  end

  add_index "part_workers", ["cost_center_id"], name: "company_id", using: :btree

  create_table "part_works", force: true do |t|
    t.integer  "working_group_id"
    t.string   "number_working_group"
    t.date     "date_of_creation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sector_id"
    t.integer  "block"
    t.integer  "cost_center_id"
    t.integer  "lock_version",         default: 0, null: false
  end

  add_index "part_works", ["cost_center_id"], name: "cost_center_id", using: :btree
  add_index "part_works", ["sector_id"], name: "sector_id", using: :btree
  add_index "part_works", ["working_group_id"], name: "working_group_id", using: :btree

  create_table "payment_orders", force: true do |t|
    t.integer  "provision_id"
    t.float    "net_pay"
    t.float    "igv"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "percent_detraction"
    t.string   "detraction"
    t.integer  "cost_center_id"
    t.string   "perception"
    t.string   "total"
    t.string   "sub_total"
    t.string   "guarantee_fund_n1"
    t.string   "other_discounts"
    t.string   "article_code"
    t.string   "type_payment"
  end

  create_table "payroll_details", force: true do |t|
    t.integer  "payroll_id"
    t.integer  "concept_id"
    t.float    "amount"
    t.string   "type_con"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payrolls", force: true do |t|
    t.integer  "worker_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payslips", force: true do |t|
    t.integer  "worker_id"
    t.integer  "cost_center_id"
    t.string   "week"
    t.integer  "days"
    t.float    "normal_hours"
    t.integer  "subsidized_day"
    t.float    "subsidized_hour"
    t.date     "last_worked_day"
    t.float    "he_60"
    t.string   "code"
    t.float    "he_100"
    t.text     "ing_and_amounts",    limit: 2147483647
    t.string   "month"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "des_and_amounts",    limit: 2147483647
    t.text     "aport_and_amounts",  limit: 2147483647
    t.integer  "company_id"
    t.integer  "type_of_payslip_id"
  end

  create_table "phases", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category"
    t.string   "code"
  end

  create_table "photo_of_works", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "photo"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "folder_id"
  end

  create_table "plutus_accounts", force: true do |t|
    t.string   "name"
    t.string   "type"
    t.boolean  "contra"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "plutus_accounts", ["name", "type"], name: "index_plutus_accounts_on_name_and_type", using: :btree

  create_table "plutus_amounts", force: true do |t|
    t.string  "type"
    t.integer "account_id"
    t.integer "entry_id"
    t.decimal "amount",     precision: 20, scale: 10
  end

  add_index "plutus_amounts", ["account_id", "entry_id"], name: "index_plutus_amounts_on_account_id_and_entry_id", using: :btree
  add_index "plutus_amounts", ["entry_id", "account_id"], name: "index_plutus_amounts_on_entry_id_and_account_id", using: :btree
  add_index "plutus_amounts", ["type"], name: "index_plutus_amounts_on_type", using: :btree

  create_table "plutus_entries", force: true do |t|
    t.string   "description"
    t.integer  "commercial_document_id"
    t.string   "commercial_document_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "plutus_entries", ["commercial_document_id", "commercial_document_type"], name: "index_entries_on_commercial_doc", using: :btree

  create_table "position_workers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "professionals", force: true do |t|
    t.string   "name"
    t.integer  "dni"
    t.date     "professional_title_date"
    t.date     "date_of_tuition"
    t.string   "professional_title"
    t.string   "professional_title_file_name"
    t.string   "professional_title_content_type"
    t.integer  "professional_title_file_size"
    t.datetime "professional_title_updated_at"
    t.string   "tuition"
    t.string   "tuition_file_name"
    t.string   "tuition_content_type"
    t.integer  "tuition_file_size"
    t.datetime "tuition_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code_tuition"
    t.string   "cv"
    t.string   "cv_file_name"
    t.string   "cv_content_type"
    t.integer  "cv_file_size"
    t.datetime "cv_updated_at"
    t.integer  "major_id"
  end

  create_table "provision_details", force: true do |t|
    t.integer  "provision_id"
    t.integer  "order_detail_id"
    t.string   "type_of_order"
    t.integer  "account_accountant_id"
    t.integer  "amount"
    t.float    "unit_price_igv"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "current_igv"
    t.float    "current_unit_price"
    t.float    "net_price_after_igv"
    t.integer  "lock_version",          default: 0,   null: false
    t.string   "article_code"
    t.string   "article_name"
    t.string   "unit_of_measurement"
    t.float    "amount_perception",     default: 0.0, null: false
    t.string   "discount_before_igv",   default: "0", null: false
    t.string   "discount_after_igv",    default: "0", null: false
  end

  add_index "provision_details", ["account_accountant_id"], name: "account_accountant_id", using: :btree
  add_index "provision_details", ["order_detail_id"], name: "order_detail_id", using: :btree
  add_index "provision_details", ["provision_id"], name: "provision_id", using: :btree

  create_table "provision_direct_extra_calculations", force: true do |t|
    t.integer  "provision_direct_purchase_detail_id"
    t.integer  "extra_calculation_id"
    t.float    "value"
    t.string   "operation"
    t.string   "type"
    t.integer  "lock_version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "apply"
  end

  create_table "provision_direct_purchase_details", force: true do |t|
    t.integer  "article_id"
    t.integer  "sector_id"
    t.integer  "phase_id"
    t.integer  "amount"
    t.string   "price"
    t.string   "unit_price_before_igv"
    t.boolean  "igv"
    t.string   "quantity_igv"
    t.string   "discount_after"
    t.string   "discount_before"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "provision_id"
    t.integer  "account_accountant_id"
    t.string   "unit_price_igv"
    t.integer  "lock_version",          default: 0, null: false
    t.integer  "flag"
    t.string   "type_order"
    t.integer  "order_id"
    t.integer  "order_detail_id"
  end

  add_index "provision_direct_purchase_details", ["article_id", "sector_id", "phase_id", "provision_id", "account_accountant_id"], name: "article_id", using: :btree

  create_table "provisions", force: true do |t|
    t.integer  "document_provision_id"
    t.string   "number_document_provision"
    t.date     "accounting_date"
    t.string   "series"
    t.integer  "entity_id"
    t.integer  "order_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cost_center_id"
    t.integer  "lock_version",              default: 0, null: false
    t.string   "number_of_guide"
  end

  add_index "provisions", ["cost_center_id"], name: "cost_center_id", using: :btree
  add_index "provisions", ["document_provision_id"], name: "document_provision_id", using: :btree
  add_index "provisions", ["entity_id"], name: "entity_id", using: :btree
  add_index "provisions", ["order_id"], name: "order_id", using: :btree

  create_table "purchase_order_details", force: true do |t|
    t.integer  "delivery_order_detail_id"
    t.string   "unit_price"
    t.boolean  "igv"
    t.string   "unit_price_igv"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "purchase_order_id"
    t.float    "amount"
    t.boolean  "received"
    t.boolean  "received_provision"
    t.string   "unit_price_before_igv"
    t.string   "quantity_igv"
    t.string   "discount_after"
    t.string   "discount_before"
    t.integer  "lock_version",             default: 0, null: false
  end

  add_index "purchase_order_details", ["delivery_order_detail_id", "purchase_order_id"], name: "delivery_order_detail_id", using: :btree

  create_table "purchase_order_extra_calculations", force: true do |t|
    t.integer  "purchase_order_detail_id"
    t.integer  "extra_calculation_id"
    t.float    "value"
    t.string   "apply"
    t.string   "operation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "lock_version",             default: 0, null: false
  end

  add_index "purchase_order_extra_calculations", ["purchase_order_detail_id", "extra_calculation_id"], name: "purchase_order_detail_id", using: :btree

  create_table "purchase_orders", force: true do |t|
    t.string   "state"
    t.date     "date_of_issue"
    t.date     "expiration_date"
    t.date     "delivery_date"
    t.boolean  "retention"
    t.integer  "money_id"
    t.integer  "method_of_payment_id"
    t.integer  "user_id"
    t.integer  "cost_center_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "exchange_of_rate"
    t.integer  "entity_id"
    t.integer  "lock_version",         default: 0, null: false
    t.string   "code"
  end

  add_index "purchase_orders", ["money_id", "method_of_payment_id", "user_id", "cost_center_id", "entity_id"], name: "money_id", using: :btree

  create_table "qa_qcs", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_of_qa_qc_id"
    t.integer  "type_of_qa_qc_supplier_id"
  end

  create_table "received_letters", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_of_received_letter_id"
    t.date     "date"
  end

  create_table "record_of_meetings", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_of_record_of_meeting_id"
  end

  create_table "rental_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rep_inv_articles", id: false, force: true do |t|
    t.integer  "user"
    t.integer  "id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rep_inv_cost_centers", id: false, force: true do |t|
    t.integer  "user"
    t.integer  "id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rep_inv_formats", id: false, force: true do |t|
    t.integer  "user"
    t.integer  "id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rep_inv_moneys", id: false, force: true do |t|
    t.integer  "user"
    t.integer  "id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rep_inv_periods", id: false, force: true do |t|
    t.integer  "user"
    t.integer  "id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rep_inv_responsibles", id: false, force: true do |t|
    t.integer  "user"
    t.integer  "id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rep_inv_suppliers", id: false, force: true do |t|
    t.integer  "user"
    t.integer  "id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rep_inv_warehouses", id: false, force: true do |t|
    t.integer  "user"
    t.integer  "id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rep_inv_years", id: false, force: true do |t|
    t.integer  "user"
    t.integer  "id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_stocks", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_valorizations", force: true do |t|
    t.integer  "valorization_id"
    t.string   "order"
    t.string   "description"
    t.float    "price"
    t.float    "con_measured"
    t.float    "con_amount"
    t.float    "pre_measured"
    t.float    "pre_amount"
    t.float    "act_measured"
    t.float    "act_amount"
    t.float    "acc_measured"
    t.float    "acc_amount"
    t.float    "rem_measured"
    t.float    "rem_amount"
    t.float    "advance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sc_valuations", force: true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "working_group"
    t.float    "valuation"
    t.float    "initial_amortization_number"
    t.float    "initial_amortization_percentage"
    t.float    "bill"
    t.float    "billigv"
    t.float    "totalbill"
    t.float    "retention"
    t.float    "detraction"
    t.float    "guarantee_fund1"
    t.float    "guarantee_fund2"
    t.float    "equipment_discount"
    t.float    "material_discount"
    t.float    "hired_amount"
    t.float    "advances"
    t.float    "accumulated_amortization"
    t.float    "balance"
    t.float    "net_payment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "accumulated_valuation"
    t.float    "accumulated_initial_amortization_number"
    t.float    "accumulated_bill"
    t.float    "accumulated_billigv"
    t.float    "accumulated_totalbill"
    t.float    "accumulated_retention"
    t.float    "accumulated_detraction"
    t.float    "accumulated_guarantee_fund1"
    t.float    "accumulated_guarantee_fund2"
    t.float    "accumulated_equipment_discount"
    t.float    "accumulated_net_payment"
    t.string   "state"
    t.string   "code"
    t.float    "otherdiscount"
    t.float    "accumulated_otherdiscount"
    t.integer  "cost_center_id"
  end

  create_table "schedule_of_workers", force: true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "state"
    t.integer  "number_workers"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sectors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.integer  "cost_center_id"
  end

  create_table "securities", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.datetime "document_updated_at"
    t.integer  "document_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "state_per_order_details", force: true do |t|
    t.integer  "delivery_order_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "state_per_order_of_services", force: true do |t|
    t.string   "state"
    t.integer  "order_of_service_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "state_per_order_purchases", force: true do |t|
    t.string   "state"
    t.integer  "purchase_order_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "state_per_warehouse_orders", force: true do |t|
    t.string   "state"
    t.integer  "warehouse_order_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_input_details", force: true do |t|
    t.integer  "stock_input_id"
    t.integer  "purchase_order_detail_id"
    t.float    "amount"
    t.string   "status"
    t.integer  "user_inserts_id"
    t.integer  "user_updates_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "article_id"
    t.integer  "equipment_id"
    t.float    "unit_cost"
    t.integer  "sector_id"
    t.integer  "phase_id"
    t.integer  "lock_version",             default: 0, null: false
  end

  add_index "stock_input_details", ["article_id"], name: "index_stock_input_details_on_article_id", using: :btree
  add_index "stock_input_details", ["phase_id"], name: "index_stock_input_details_on_phase_id", using: :btree
  add_index "stock_input_details", ["purchase_order_detail_id"], name: "index_stock_input_details_on_purchase_order_detail_id", using: :btree
  add_index "stock_input_details", ["sector_id"], name: "index_stock_input_details_on_sector_id", using: :btree
  add_index "stock_input_details", ["stock_input_id"], name: "index_stock_input_details_on_stock_input_id", using: :btree

  create_table "stock_inputs", force: true do |t|
    t.integer  "warehouse_id"
    t.integer  "period"
    t.string   "document"
    t.integer  "format_id"
    t.date     "issue_date"
    t.string   "description"
    t.string   "status"
    t.integer  "user_inserts_id"
    t.integer  "user_updates_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "input"
    t.integer  "year"
    t.integer  "working_group_id"
    t.integer  "company_id"
    t.integer  "cost_center_id"
    t.integer  "responsible_id"
    t.integer  "supplier_id"
    t.string   "series"
    t.integer  "lock_version",     default: 0, null: false
  end

  add_index "stock_inputs", ["company_id"], name: "index_stock_inputs_on_company_id", using: :btree
  add_index "stock_inputs", ["cost_center_id"], name: "index_stock_inputs_on_cost_center_id", using: :btree
  add_index "stock_inputs", ["format_id"], name: "index_stock_inputs_on_format_id", using: :btree
  add_index "stock_inputs", ["warehouse_id"], name: "index_stock_inputs_on_warehouse_id", using: :btree
  add_index "stock_inputs", ["working_group_id"], name: "index_stock_inputs_on_working_group_id", using: :btree

  create_table "sub_dailies", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subcontract_advances", force: true do |t|
    t.date     "date_of_issue"
    t.float    "advance"
    t.integer  "subcontract_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",   default: 0, null: false
  end

  create_table "subcontract_details", force: true do |t|
    t.integer  "article_id"
    t.integer  "amount"
    t.float    "unit_price"
    t.float    "partial"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subcontract_id"
    t.integer  "itembybudget_id"
    t.integer  "lock_version",    default: 0, null: false
  end

  create_table "subcontract_equipment_advances", force: true do |t|
    t.date     "date_of_issue"
    t.float    "advance"
    t.integer  "subcontract_equipment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",             default: 0, null: false
  end

  create_table "subcontract_equipment_details", force: true do |t|
    t.integer  "article_id"
    t.string   "description"
    t.string   "brand"
    t.string   "series"
    t.string   "model"
    t.date     "date_in"
    t.integer  "year"
    t.float    "price_no_igv"
    t.integer  "rental_type_id"
    t.string   "minimum_hours"
    t.integer  "amount_hours"
    t.float    "contracted_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subcontract_equipment_id"
    t.string   "code"
    t.integer  "lock_version",             default: 0, null: false
    t.string   "state"
  end

  create_table "subcontract_equipments", force: true do |t|
    t.integer  "entity_id"
    t.string   "valorization"
    t.string   "terms_of_payment"
    t.float    "initial_amortization_number"
    t.string   "initial_amortization_percent"
    t.string   "guarantee_fund"
    t.string   "detraction"
    t.float    "contract_amount"
    t.string   "igv"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cost_center_id"
    t.string   "contract_description"
    t.integer  "lock_version",                 default: 0, null: false
  end

  create_table "subcontracts", force: true do |t|
    t.integer  "entity_id"
    t.string   "valorization"
    t.string   "terms_of_payment"
    t.float    "initial_amortization_number"
    t.string   "initial_amortization_percent"
    t.string   "guarantee_fund"
    t.string   "detraction"
    t.float    "contract_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.float    "igv"
    t.integer  "cost_center_id"
    t.integer  "lock_version",                 default: 0, null: false
  end

  create_table "technical_files", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_of_technical_file_id"
  end

  create_table "technical_libraries", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_update_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type_of_cost_center"
  end

  create_table "technical_libraries_type_of_technical_libraries", force: true do |t|
    t.integer  "technical_library_id"
    t.integer  "type_of_technical_library_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "technical_standards", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_update_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type_of_cost_center"
  end

  create_table "testimony_of_consortium_documents", force: true do |t|
    t.string   "attachment"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.string   "attachment_file_size"
    t.datetime "attachment_update_at"
    t.integer  "work_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "theoretical_values", force: true do |t|
    t.integer  "article_id"
    t.float    "theoretical_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "total_hours_per_week_per_cost_center_1", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_10", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_11", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_12", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_13", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_14", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_15", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_16", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_17", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_18", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_19", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_2", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_20", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_21", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_22", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_23", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_24", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_25", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_26", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_27", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_3", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_4", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_5", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_6", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_7", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_8", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "total_hours_per_week_per_cost_center_9", force: true do |t|
    t.integer "week_id"
    t.float   "total"
    t.integer "status"
  end

  create_table "trainings", force: true do |t|
    t.integer  "professional_id"
    t.string   "type_training"
    t.string   "training"
    t.string   "training_file_name"
    t.string   "training_content_type"
    t.integer  "training_file_size"
    t.datetime "training_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name_training"
    t.integer  "num_hours"
    t.date     "start_training"
    t.date     "finish_training"
  end

  create_table "type_entities", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_articles", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_book_works", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_companies", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_contest_documents", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_contractual_documents", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_issued_letters", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_land_deliveries", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_law_and_regulations", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_modification_files", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_payslips", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "for_worker_employee"
    t.integer  "type_of_worker_id"
    t.integer  "type_of_payslips_id"
    t.string   "type_operation"
    t.string   "name_operation"
    t.string   "type_converted_operation"
    t.integer  "cost_center_id"
  end

  create_table "type_of_qa_qc_qualities", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_qa_qc_suppliers", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_received_letters", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_record_of_meetings", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_technical_files", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_technical_libraries", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_valorization_docs", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_work_reports", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_of_workers", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "prefix"
    t.string   "worker_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_workdays", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "type_workdays_workers", force: true do |t|
    t.integer "worker_id"
    t.integer "type_workday_id"
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

  create_table "valorization_by_categories", force: true do |t|
    t.integer  "valorization_id"
    t.string   "category_id"
    t.float    "amount"
    t.integer  "budget_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "valorization_docs", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.integer  "type_of_valorization_doc_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "valorizationitems", force: true do |t|
    t.integer  "valorization_id"
    t.integer  "itembybudget_id"
    t.float    "actual_measured"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "accumulated_measured"
  end

  create_table "valorizations", force: true do |t|
    t.string   "month"
    t.string   "name"
    t.string   "status"
    t.integer  "budget_id"
    t.float    "general_expenses"
    t.float    "utility"
    t.float    "readjustment"
    t.float    "no_direct_r"
    t.float    "no_materials_r"
    t.float    "direct_advance"
    t.float    "advance_of_materials"
    t.date     "valorization_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "valuation_of_equipments", force: true do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "working_group"
    t.float    "valuation"
    t.float    "initial_amortization_number"
    t.float    "initial_amortization_percentage"
    t.float    "bill"
    t.string   "billigv"
    t.string   "totalbill"
    t.float    "retention"
    t.float    "detraction"
    t.float    "fuel_discount"
    t.float    "other_discount"
    t.float    "hired_amount"
    t.float    "advances"
    t.float    "accumulated_amortization"
    t.float    "balance"
    t.string   "net_payment"
    t.float    "accumulated_valuation"
    t.float    "accumulated_initial_amortization_number"
    t.float    "accumulated_bill"
    t.float    "accumulated_billigv"
    t.float    "accumulated_totalbill"
    t.string   "accumulated_retention"
    t.string   "accumulated_detraction"
    t.float    "accumulated_fuel_discount"
    t.float    "accumulated_other_discount"
    t.string   "accumulated_net_payment"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.integer  "subcontract_equipment_id"
    t.boolean  "locked"
  end

  create_table "warehouse_order_details", force: true do |t|
    t.integer  "article_id"
    t.integer  "quantity"
    t.integer  "sector_id"
    t.integer  "phase_id"
    t.integer  "warehouse_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "warehouse_orders", force: true do |t|
    t.string   "code"
    t.integer  "working_group_id"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cost_center_id"
    t.string   "state"
    t.integer  "user_id"
  end

  create_table "warehouses", force: true do |t|
    t.string   "name"
    t.string   "location"
    t.string   "status"
    t.integer  "cost_center_id"
    t.integer  "user_inserts_id"
    t.integer  "user_updates_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
  end

  add_index "warehouses", ["company_id"], name: "index_warehouses_on_company_id", using: :btree
  add_index "warehouses", ["cost_center_id"], name: "index_warehouses_on_cost_center_id", using: :btree

  create_table "watchdogs", force: true do |t|
    t.string   "user_id"
    t.string   "browser"
    t.string   "ip_address"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wbsitems", force: true do |t|
    t.string   "codewbs"
    t.string   "name"
    t.string   "description"
    t.string   "notes"
    t.integer  "cost_center_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "predecessors"
    t.string   "fase_id"
    t.string   "fase"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "phase_id"
  end

  create_table "weekly_workers", force: true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.string   "working_group"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.string   "number_workers"
    t.integer  "cost_center_id"
  end

  create_table "weeks_for_cost_center_1", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_10", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_11", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_12", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_13", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_14", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_15", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_16", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_17", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_18", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_19", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_2", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_20", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_21", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_22", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_23", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_24", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_25", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_26", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_27", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_3", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_4", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_5", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_6", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_7", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_8", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "weeks_for_cost_center_9", force: true do |t|
    t.string "name"
    t.date   "start_date"
    t.date   "end_date"
  end

  create_table "work_partners", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ruc"
    t.text     "address"
  end

  create_table "work_partners_works", force: true do |t|
    t.integer  "work_id"
    t.integer  "work_partner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "work_reports", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "cost_center_id"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_of_work_report_id"
  end

  create_table "worker_afps", force: true do |t|
    t.integer  "afp_id"
    t.string   "afptype"
    t.integer  "worker_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "afpnumber"
  end

  add_index "worker_afps", ["afp_id", "worker_id"], name: "afp_id", using: :btree

  create_table "worker_center_of_studies", force: true do |t|
    t.string   "name"
    t.string   "profession"
    t.string   "title"
    t.string   "numberoftuition"
    t.integer  "start_date"
    t.integer  "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "worker_id"
    t.integer  "lock_version",    default: 0, null: false
  end

  add_index "worker_center_of_studies", ["worker_id"], name: "worker_id", using: :btree

  create_table "worker_contract_details", force: true do |t|
    t.integer  "worker_id"
    t.integer  "worker_contract_id"
    t.integer  "concept_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "worker_contracts", force: true do |t|
    t.integer  "article_id"
    t.float    "camp"
    t.float    "destaque"
    t.float    "salary"
    t.string   "regime"
    t.integer  "days"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "worker_id"
    t.string   "numberofcontract"
    t.string   "typeofcontract"
    t.date     "end_date_2"
    t.integer  "contract_type_id"
    t.string   "reason_for_termination"
    t.float    "viatical"
    t.float    "bonus"
    t.integer  "status"
    t.string   "comment"
    t.string   "document"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "lock_version",           default: 0, null: false
  end

  add_index "worker_contracts", ["article_id", "worker_id", "contract_type_id"], name: "article_id", using: :btree

  create_table "worker_details", force: true do |t|
    t.integer  "bank_id"
    t.string   "account_number"
    t.integer  "worker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version",   default: 0, null: false
  end

  add_index "worker_details", ["bank_id"], name: "bank_id", using: :btree

  create_table "worker_experiences", force: true do |t|
    t.string   "businessname"
    t.string   "title"
    t.float    "salary"
    t.string   "bossincharge"
    t.string   "exitreason"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "worker_id"
    t.integer  "lock_version", default: 0, null: false
  end

  add_index "worker_experiences", ["businessname", "worker_id"], name: "businessname", using: :btree

  create_table "worker_familiars", force: true do |t|
    t.string   "paternal_surname"
    t.string   "maternal_surname"
    t.string   "names"
    t.string   "relationship"
    t.date     "dayofbirth"
    t.string   "dni"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "worker_id"
    t.integer  "lock_version",     default: 0, null: false
  end

  add_index "worker_familiars", ["dni", "worker_id"], name: "dni", using: :btree

  create_table "worker_healths", force: true do |t|
    t.integer  "health_center_id"
    t.integer  "worker_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "health_regime"
    t.integer  "lock_version",     default: 0, null: false
  end

  add_index "worker_healths", ["health_center_id", "worker_id", "health_regime"], name: "health_center_id", using: :btree

  create_table "worker_otherstudies", force: true do |t|
    t.string   "study"
    t.string   "level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "worker_id"
    t.integer  "lock_version", default: 0, null: false
  end

  add_index "worker_otherstudies", ["worker_id"], name: "worker_id", using: :btree

  create_table "worker_rent_fifth_categories", force: true do |t|
    t.integer  "worker_id"
    t.float    "previous_salary"
    t.float    "rent"
    t.date     "date_last_rent"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workers", force: true do |t|
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position_worker_id"
    t.integer  "entity_id"
    t.string   "email"
    t.integer  "cost_center_id"
    t.string   "address"
    t.string   "district"
    t.string   "province"
    t.string   "department"
    t.string   "pais"
    t.string   "cellphone"
    t.string   "primaryschool"
    t.string   "highschool"
    t.string   "primarydistrict"
    t.string   "highschooldistrict"
    t.integer  "primarystartdate"
    t.integer  "primaryenddate"
    t.integer  "highschoolstartdate"
    t.integer  "highschoolenddate"
    t.string   "levelofinstruction"
    t.string   "quality"
    t.string   "security"
    t.string   "enviroment"
    t.string   "labor_legislation"
    t.string   "cv"
    t.string   "cv_file_name"
    t.string   "cv_content_type"
    t.integer  "cv_file_size"
    t.datetime "cv_updated_at"
    t.string   "antecedent_police"
    t.string   "antecedent_police_file_name"
    t.string   "antecedent_police_content_type"
    t.integer  "antecedent_police_file_size"
    t.datetime "antecedent_police_updated_at"
    t.string   "dni"
    t.string   "dni_file_name"
    t.string   "dni_content_type"
    t.integer  "dni_file_size"
    t.datetime "dni_updated_at"
    t.string   "cts_deposit_letter"
    t.string   "cts_deposit_letter_file_name"
    t.string   "cts_deposit_letter_content_type"
    t.integer  "cts_deposit_letter_file_size"
    t.datetime "cts_deposit_letter_updated_at"
    t.string   "pension_funds_letter"
    t.string   "pension_funds_letter_file_name"
    t.string   "pension_funds_letter_content_type"
    t.integer  "pension_funds_letter_file_size"
    t.datetime "pension_funds_letter_updated_at"
    t.string   "affidavit"
    t.string   "affidavit_file_name"
    t.string   "affidavit_content_type"
    t.integer  "affidavit_file_size"
    t.datetime "affidavit_updated_at"
    t.string   "marriage_certificate"
    t.string   "marriage_certificate_file_name"
    t.string   "marriage_certificate_content_type"
    t.integer  "marriage_certificate_file_size"
    t.datetime "marriage_certificate_updated_at"
    t.string   "birth_certificate_of_childer"
    t.string   "birth_certificate_of_childer_file_name"
    t.string   "birth_certificate_of_childer_content_type"
    t.integer  "birth_certificate_of_childer_file_size"
    t.datetime "birth_certificate_of_childer_updated_at"
    t.string   "dni_wife_kids"
    t.string   "dni_wife_kids_file_name"
    t.string   "dni_wife_kids_content_type"
    t.integer  "dni_wife_kids_file_size"
    t.datetime "dni_wife_kids_updated_at"
    t.string   "schoolar_certificate"
    t.string   "schoolar_certificate_file_name"
    t.string   "schoolar_certificate_content_type"
    t.integer  "schoolar_certificate_file_size"
    t.datetime "schoolar_certificate_updated_at"
    t.string   "driverlicense"
    t.string   "maritalstatus"
    t.string   "typeofworker"
    t.integer  "numberofchilds"
    t.string   "disabled"
    t.string   "unionized"
    t.string   "state"
    t.string   "income_fifth_category"
    t.string   "lastgrade"
    t.integer  "position_wg_id"
    t.string   "number_position"
    t.integer  "lock_version",                              default: 0, null: false
    t.integer  "type_of_worker_id"
  end

  add_index "workers", ["position_worker_id", "entity_id", "cost_center_id"], name: "position_worker_id", using: :btree

  create_table "working_groups", force: true do |t|
    t.integer  "master_builder_id"
    t.integer  "front_chief_id"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "executor_id"
    t.integer  "user_inserts_id"
    t.integer  "user_updates_id"
    t.string   "name"
    t.integer  "cost_center_id"
  end

  add_index "working_groups", ["master_builder_id", "front_chief_id", "executor_id", "user_inserts_id", "user_updates_id", "cost_center_id"], name: "master_builder_id", using: :btree

  create_table "works", force: true do |t|
    t.string   "specialty"
    t.string   "name"
    t.float    "amount_of_contract"
    t.string   "participation_of_arsac"
    t.date     "date_signature_of_contract"
    t.date     "start_date_of_work"
    t.date     "real_end_date_of_work"
    t.date     "date_of_receipt_of_work"
    t.date     "settlement_date"
    t.float    "amount_of_settlement"
    t.float    "ipc_settlement"
    t.integer  "component_id"
    t.string   "testimony_of_consortium"
    t.string   "testimony_of_consortium_file_name"
    t.string   "testimony_of_consortium_content_type"
    t.integer  "testimony_of_consortium_file_size"
    t.datetime "testimony_of_consortium_updated_at"
    t.string   "contract"
    t.string   "contract_file_name"
    t.string   "contract_content_type"
    t.integer  "contract_file_size"
    t.datetime "contract_updated_at"
    t.string   "reception_certificate"
    t.string   "reception_certificate_file_name"
    t.string   "reception_certificate_content_type"
    t.integer  "reception_certificate_file_size"
    t.datetime "reception_certificate_updated_at"
    t.string   "settlement_of_work"
    t.string   "settlement_of_work_file_name"
    t.string   "settlement_of_work_content_type"
    t.integer  "settlement_of_work_file_size"
    t.datetime "settlement_of_work_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "entity_id"
    t.date     "start_date_of_inquiry"
    t.date     "end_date_of_inquiry"
    t.string   "budget"
    t.string   "budget_file_name"
    t.string   "budget_content_type"
    t.integer  "budget_file_size"
    t.datetime "budget_updated_at"
    t.string   "integrated_bases"
    t.string   "integrated_bases_file_name"
    t.string   "integrated_bases_content_type"
    t.integer  "integrated_bases_file_size"
    t.datetime "integrated_bases_updated_at"
    t.string   "arbitration"
    t.string   "arbitration_file_name"
    t.string   "arbitration_content_type"
    t.integer  "arbitration_file_size"
    t.datetime "arbitration_updated_at"
    t.string   "procurement_system"
    t.string   "procurement_system_file_name"
    t.string   "procurement_system_content_type"
    t.integer  "procurement_system_file_size"
    t.datetime "procurement_system_update_at"
    t.string   "purpose_of_contract"
    t.integer  "contractor_id"
    t.integer  "money_id"
    t.string   "exchange_of_rate"
    t.string   "number_of_settlement"
    t.string   "compliance_work"
    t.string   "compliance_work_file_name"
    t.string   "compliance_work_content_type"
    t.integer  "compliance_work_file_size"
    t.datetime "compliance_work_update_at"
    t.string   "amount_contract_of_inquiry"
    t.string   "amount_settlement_of_inquiry"
    t.string   "amount_contract_of_is"
    t.string   "amount_settlement_of_is"
  end

  create_table "zip_codes", force: true do |t|
    t.string   "name"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
