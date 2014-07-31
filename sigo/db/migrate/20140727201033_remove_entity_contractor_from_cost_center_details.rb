class RemoveEntityContractorFromCostCenterDetails < ActiveRecord::Migration
  def change
  	remove_column :cost_center_details, :entity_id
  	remove_column :cost_center_details, :contractor_id
  end
end
