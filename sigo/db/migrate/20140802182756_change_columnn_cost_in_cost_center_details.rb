class ChangeColumnnCostInCostCenterDetails < ActiveRecord::Migration
  def change
  	change_column :cost_center_details, :referential_value,  :string
  	change_column :cost_center_details, :earned_value,  :string
  	change_column :cost_center_details, :direct_cost,  :string
  	change_column :cost_center_details, :general_cost,  :string
  	change_column :cost_center_details, :utility,  :string
  	change_column :cost_center_details, :IGV,  :string
  end
end
