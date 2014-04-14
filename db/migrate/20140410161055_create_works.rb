class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works do |t|
      t.string :specialty
      t.string :contracting_entity
      t.string :name
      t.float :amount_of_contract
      t.string :contractor
      t.string :participation_of_arsac
      t.date :date_signature_of_contract
      t.date :start_date_of_work
      t.date :real_end_date_of_work
      t.date :date_of_receipt_of_work
      t.date :settlement_date
      t.float :amount_of_settlement
      t.float :ipc_settlement
      t.integer :component_id
      t.string :testimony_of_consortium
      t.string :testimony_of_consortium_file_name
      t.string :testimony_of_consortium_content_type
      t.integer :testimony_of_consortium_file_size
      t.datetime :testimony_of_consortium_updated_at
      t.string :contract
      t.string :contract_file_name
      t.string :contract_content_type
      t.integer :contract_file_size
      t.datetime :contract_updated_at
      t.string :reception_certificate
      t.string :reception_certificate_file_name
      t.string :reception_certificate_content_type
      t.integer :reception_certificate_file_size
      t.datetime :reception_certificate_updated_at
      t.string :settlement_of_work
      t.string :settlement_of_work_file_name
      t.string :settlement_of_work_content_type
      t.integer :settlement_of_work_file_size
      t.datetime :settlement_of_work_updated_at

      t.timestamps
    end
  end
end
