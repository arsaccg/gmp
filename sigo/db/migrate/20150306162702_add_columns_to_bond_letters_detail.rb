class AddColumnsToBondLettersDetail < ActiveRecord::Migration
  def change
    add_column :bond_letter_details, :document, :string
    add_column :bond_letter_details, :document_file_name, :string
    add_column :bond_letter_details, :document_content_type, :string
    add_column :bond_letter_details, :document_file_size, :integer
    add_column :bond_letter_details, :document_updated_at, :datetime
  end
end
