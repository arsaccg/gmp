class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :valorization_id
      t.float :amount
      t.date :issue_date
      t.date :filing_date
      t.string :status
      t.string :credit_note
      t.string :observations
      t.string :document_number

      t.timestamps
    end
  end
end
