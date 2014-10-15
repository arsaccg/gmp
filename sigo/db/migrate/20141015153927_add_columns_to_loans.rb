class AddColumnsToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :cost_center_beneficiary_id, :integer
    add_column :loans, :cost_center_lender_id, :integer
	rename_column :loans, :beneficiary, :person
	remove_column :loans, :entity_id
  end
end
