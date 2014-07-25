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

ActiveRecord::Schema.define(version: 20140725150126) do

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

  create_table "banks", force: true do |t|
    t.string   "business_name"
    t.string   "ruc"
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
  end

  create_table "center_of_attentions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation"
    t.integer  "cost_center_id"
  end

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

  create_table "certificates_professionals", force: true do |t|
    t.integer  "certificate_id"
    t.integer  "professional_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

  create_table "companies_users", force: true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "components_works", force: true do |t|
    t.integer  "work_id"
    t.integer  "component_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "components_works", ["work_id", "component_id"], name: "index_components_works_on_work_id_and_component_id", using: :btree

  create_table "componets_other_works", force: true do |t|
    t.integer  "component_id"
    t.integer  "other_works_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "concept_details", force: true do |t|
    t.integer  "concept_id"
    t.integer  "subconcept_id"
    t.string   "category"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "concepts", force: true do |t|
    t.string   "name"
    t.float    "percentage"
    t.float    "amount"
    t.string   "code"
    t.float    "top"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type_concept"
    t.integer  "status"
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

  create_table "cost_center_timelines", force: true do |t|
    t.integer "cost_center_id"
    t.date    "date"
    t.integer "year"
    t.integer "period"
    t.integer "week"
    t.integer "day"
  end

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
  end

  create_table "cost_centers_users", force: true do |t|
    t.integer  "cost_center_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_summary_accountings", force: true do |t|
    t.integer  "account_accountant_id"
    t.integer  "sub_daily_id"
    t.date     "accounting_date"
    t.float    "amount"
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
    t.integer  "amount"
    t.text     "description"
    t.integer  "delivery_order_id"
    t.date     "scheduled_date"
    t.integer  "center_of_attention_id"
    t.boolean  "requested"
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
  end

  create_table "entities_type_entities", force: true do |t|
    t.integer  "entity_id"
    t.integer  "type_entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entities_type_entities", ["entity_id", "type_entity_id"], name: "index_entities_type_entities_on_entity_id_and_type_entity_id", using: :btree

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
  end

  create_table "extra_calculations", force: true do |t|
    t.string   "concept"
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

  create_table "graphers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "health_centers", force: true do |t|
    t.string   "enterprise"
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
    t.float    "price"
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
  end

  add_index "itembybudgets", ["item_id"], name: "itembybudges_item_id", using: :btree

  create_table "itembywbs", force: true do |t|
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
    t.integer  "amount"
    t.float    "unit_price"
    t.boolean  "igv"
    t.integer  "unit_price_igv"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_of_service_id"
    t.boolean  "received"
    t.float    "unit_price_before_igv"
  end

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
  end

  create_table "order_service_extra_calculations", force: true do |t|
    t.integer  "order_of_service_detail_id"
    t.integer  "extra_calculation_id"
    t.float    "value"
    t.string   "apply"
    t.string   "operation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

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
  end

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
  end

  create_table "part_people", force: true do |t|
    t.integer  "working_group_id"
    t.string   "number_part"
    t.date     "date_of_creation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "block"
    t.integer  "blockweekly"
    t.integer  "cost_center_id"
  end

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
  end

  create_table "part_work_details", force: true do |t|
    t.integer  "part_work_id"
    t.integer  "article_id"
    t.float    "bill_of_quantitties"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "part_works", force: true do |t|
    t.integer  "working_group_id"
    t.string   "number_working_group"
    t.date     "date_of_creation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sector_id"
    t.integer  "block"
    t.integer  "cost_center_id"
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
  end

  create_table "position_workers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "professional_certificates", force: true do |t|
    t.integer  "professional_id"
    t.integer  "certificate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "professional_trainings", force: true do |t|
    t.integer  "professional_id"
    t.integer  "training_id"
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
  end

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
  end

  create_table "purchase_order_details", force: true do |t|
    t.integer  "delivery_order_detail_id"
    t.float    "unit_price"
    t.boolean  "igv"
    t.float    "unit_price_igv"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "purchase_order_id"
    t.integer  "amount"
    t.boolean  "received"
    t.boolean  "received_provision"
    t.float    "unit_price_before_igv"
  end

  create_table "purchase_order_extra_calculations", force: true do |t|
    t.integer  "purchase_order_detail_id"
    t.integer  "extra_calculation_id"
    t.float    "value"
    t.string   "apply"
    t.string   "operation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

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

  create_table "sectors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.integer  "cost_center_id"
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
  end

  create_table "subcontract_equipment_advances", force: true do |t|
    t.date     "date_of_issue"
    t.float    "advance"
    t.integer  "subcontract_equipment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "type_of_law_and_regulations", force: true do |t|
    t.string   "name"
    t.string   "preffix"
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

  create_table "type_of_work_reports", force: true do |t|
    t.string   "name"
    t.string   "preffix"
    t.integer  "cost_center_id"
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
    t.float    "billigv"
    t.float    "totalbill"
    t.float    "retention"
    t.float    "detraction"
    t.float    "fuel_discount"
    t.float    "other_discount"
    t.float    "hired_amount"
    t.float    "advances"
    t.float    "accumulated_amortization"
    t.float    "balance"
    t.float    "net_payment"
    t.float    "accumulated_valuation"
    t.float    "accumulated_initial_amortization_number"
    t.float    "accumulated_bill"
    t.float    "accumulated_billigv"
    t.float    "accumulated_totalbill"
    t.float    "accumulated_retention"
    t.float    "accumulated_detraction"
    t.float    "accumulated_fuel_discount"
    t.float    "accumulated_other_discount"
    t.float    "accumulated_net_payment"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
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
    t.string   "afpnumber"
    t.integer  "worker_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "worker_center_of_studies", force: true do |t|
    t.string   "name"
    t.string   "profession"
    t.string   "title"
    t.string   "numberoftuition"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "worker_id"
  end

  create_table "worker_contracts", force: true do |t|
    t.integer  "charge_id"
    t.float    "camp"
    t.float    "destaque"
    t.float    "salary"
    t.integer  "regime"
    t.integer  "days"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "worker_id"
    t.integer  "numberofcontract"
    t.string   "typeofcontract"
    t.date     "end_date_2"
  end

  create_table "worker_details", force: true do |t|
    t.integer  "bank_id"
    t.string   "account_number"
    t.integer  "worker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "worker_experiences", force: true do |t|
    t.string   "businessname"
    t.string   "businessaddress"
    t.string   "title"
    t.float    "salary"
    t.string   "bossincharge"
    t.string   "exitreason"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "worker_id"
  end

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
  end

  create_table "worker_healths", force: true do |t|
    t.integer  "health_id"
    t.integer  "worker_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "worker_otherstudies", force: true do |t|
    t.string   "study"
    t.string   "level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "worker_id"
  end

  create_table "workers", force: true do |t|
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position_worker_id"
    t.integer  "article_id"
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
    t.date     "primarystartdate"
    t.date     "primaryenddate"
    t.date     "highschoolstartdate"
    t.date     "highschoolenddate"
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
  end

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
