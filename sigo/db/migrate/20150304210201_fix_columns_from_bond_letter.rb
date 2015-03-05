class FixColumnsFromBondLetter < ActiveRecord::Migration
  def change
  	rename_column :bond_letter_details, :retention, :retention_amount
  	add_column :bond_letter_details, :retention_percentage, :float
  end
end
