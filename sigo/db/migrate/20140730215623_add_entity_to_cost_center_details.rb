class AddEntityToCostCenterDetails < ActiveRecord::Migration
  def change
  	add_column :cost_center_details, :entity, :string
  	remove_column :cost_center_details, :participation
  end
end
