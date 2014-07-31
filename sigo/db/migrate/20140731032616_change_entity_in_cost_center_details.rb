class ChangeEntityInCostCenterDetails < ActiveRecord::Migration
  def change
  	add_column :cost_center_details, :entity_id, :int
  	remove_column :cost_center_details, :entity
  end
end
