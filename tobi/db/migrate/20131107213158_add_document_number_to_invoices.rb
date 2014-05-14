class AddDocumentNumberToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :document_number, :string
  end
end
