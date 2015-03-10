class FixColumnsInBondLetterDetails < ActiveRecord::Migration
  def change
  	change_column :bond_letter_details, :amount, :string
  	change_column :bond_letter_details, :issuance_cost, :string
  	change_column :bond_letter_details, :retention_amount, :string
  	change_column :bond_letter_details, :rate, :string

  end
end
