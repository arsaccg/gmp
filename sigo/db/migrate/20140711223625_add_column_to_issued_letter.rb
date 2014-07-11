class AddColumnToIssuedLetter < ActiveRecord::Migration
  def change
    add_column :issued_letters, :type_of_doc, :string
  end
end
