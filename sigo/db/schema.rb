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

ActiveRecord::Schema.define(version: 20140521220243) do

  create_table "advances", force: true do |t|
    t.string   "advance_type"
    t.integer  "advance_number"
    t.float    "advance_direct_cost_percent"
    t.float    "amount"
    t.integer  "cost_center_id"
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

  create_table "articles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "code"
    t.integer  "type_of_article_id"
    t.integer  "unit_of_measurement_id"
    t.integer  "specific_id"
  end

  create_table "attachment_arbitration_documents", force: true do |t|
    t.string   "attachment"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_update_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachment_contract_documents", force: true do |t|
    t.string   "attachment"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_update_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachment_integrated_bases_documents", force: true do |t|
    t.string   "attachment"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_update_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachment_testimony_of_consortium_documents", force: true do |t|
    t.string   "attachment"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_update_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "banks", force: true do |t|
    t.string   "business_name"
    t.string   "ruc"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "name"
    t.float    "normal_price"
    t.float    "he_60_price"
    t.float    "he_100_price"
    t.integer  "unit_of_measurement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "center_of_attentions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbreviation"
  end

  create_table "certificates", force: true do |t|
    t.integer  "professional_id"
    t.integer  "work_id"
    t.integer  "charge_id"
    t.date     "start_date"
    t.date     "finish_date"
    t.integer  "componetns_id"
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

  create_table "components_works", force: true do |t|
    t.integer  "work_id"
    t.integer  "component_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "components_works", ["work_id", "component_id"], name: "index_components_works_on_work_id_and_component_id", using: :btree

  create_table "componet", id: false, force: true do |t|
    t.integer "id",   null: false
    t.integer "type", null: false
  end

  create_table "componets_other_works", force: true do |t|
    t.integer  "component_id"
    t.integer  "other_works_id"
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  create_table "cost_centers_users", force: true do |t|
    t.integer  "cost_center_id"
    t.integer  "user_id"
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

  create_table "financial_variables", force: true do |t|
    t.string   "name"
    t.float    "value"
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
  end

  add_index "inputbybudgetanditems", ["cod_input"], name: "cod_input_index", using: :btree
  add_index "inputbybudgetanditems", ["cod_input"], name: "inputbybudgetanditems_codinput", using: :btree
  add_index "inputbybudgetanditems", ["id"], name: "inputbybudgets_id", using: :btree
  add_index "inputbybudgetanditems", ["item_id"], name: "inputbybudgets_item_id", using: :btree
  add_index "inputbybudgetanditems", ["order"], name: "inputbybudgets_order", using: :btree

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
  end

  create_table "part_people", force: true do |t|
    t.integer  "working_group_id"
    t.string   "number_part"
    t.date     "date_of_creation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "part_person_details", force: true do |t|
    t.integer  "worker_id"
    t.integer  "phase_id"
    t.integer  "normal_hours"
    t.integer  "he_60"
    t.integer  "he_100"
    t.integer  "total_hours"
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
  end

  create_table "phases", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category"
    t.string   "code"
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

  create_table "sectors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
  end

  create_table "specifics", force: true do |t|
    t.integer  "subcategory_id"
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
    t.decimal  "amount",                   precision: 15, scale: 5
    t.string   "status"
    t.integer  "user_inserts_id"
    t.integer  "user_updates_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "article_id"
    t.integer  "equipment_id"
    t.decimal  "unit_cost",                precision: 15, scale: 5
  end

  add_index "stock_input_details", ["article_id"], name: "index_stock_input_details_on_article_id", using: :btree
  add_index "stock_input_details", ["purchase_order_detail_id"], name: "index_stock_input_details_on_purchase_order_detail_id", using: :btree
  add_index "stock_input_details", ["stock_input_id"], name: "index_stock_input_details_on_stock_input_id", using: :btree

  create_table "stock_inputs", force: true do |t|
    t.integer  "warehouse_id"
    t.integer  "supplier_id"
    t.integer  "period"
    t.string   "series"
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
    t.integer  "phase_id"
    t.integer  "working_group_id"
    t.integer  "company_id"
    t.integer  "cost_center_id"
    t.integer  "responsible_id"
  end

  add_index "stock_inputs", ["company_id"], name: "index_stock_inputs_on_company_id", using: :btree
  add_index "stock_inputs", ["cost_center_id"], name: "index_stock_inputs_on_cost_center_id", using: :btree
  add_index "stock_inputs", ["format_id"], name: "index_stock_inputs_on_format_id", using: :btree
  add_index "stock_inputs", ["phase_id"], name: "index_stock_inputs_on_phase_id", using: :btree
  add_index "stock_inputs", ["warehouse_id"], name: "index_stock_inputs_on_warehouse_id", using: :btree
  add_index "stock_inputs", ["working_group_id"], name: "index_stock_inputs_on_working_group_id", using: :btree

  create_table "subcategories", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
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
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subcontract_inputs", force: true do |t|
    t.integer  "article_id"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  create_table "suppliers", force: true do |t|
    t.string "ruc"
    t.string "name"
    t.string "address"
    t.string "phone"
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

  create_table "worker_details", force: true do |t|
    t.integer  "bank_id"
    t.string   "account_number"
    t.integer  "worker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workers", force: true do |t|
    t.string   "first_name"
    t.string   "paternal_surname"
    t.string   "maternal_surname"
    t.string   "email"
    t.string   "phone"
    t.date     "date_of_birth"
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dni"
    t.integer  "category_of_worker_id"
    t.string   "second_name"
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
  end

  create_table "works", force: true do |t|
    t.string   "specialty"
    t.string   "name",                                 limit: 500
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
