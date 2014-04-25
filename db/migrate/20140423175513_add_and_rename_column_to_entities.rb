class AddAndRenameColumnToEntities < ActiveRecord::Migration
  def change
    rename_column :entities, :surname, :paternal_surname
    add_column :entities, :maternal_surname, :string
  end
end
