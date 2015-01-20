class AddColumnsForAttDocToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :loan_doc, :string
    add_column :loans, :loan_doc_file_name, :string
    add_column :loans, :loan_doc_content_type, :string
    add_column :loans, :loan_doc_file_size, :integer
    add_column :loans, :loan_doc_update_at, :datetime
    add_column :loans, :refund_doc, :string
    add_column :loans, :refund_doc_file_name, :string
    add_column :loans, :refund_doc_content_type, :string
    add_column :loans, :refund_doc_file_size, :integer
    add_column :loans, :refund_doc_update_at, :datetime
  end
end
