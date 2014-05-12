class AddColumnSubcontractIdToSubcontractDetails < ActiveRecord::Migration
  def change
    add_column :subcontract_details, :subcontract_id, :integer
  end
end
