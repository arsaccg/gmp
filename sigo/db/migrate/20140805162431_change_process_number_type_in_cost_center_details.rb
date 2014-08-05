class ChangeProcessNumberTypeInCostCenterDetails < ActiveRecord::Migration
  def change
  	change_column :cost_center_details, :process_number,  :string
  	change_column :cost_center_details, :contract_number,  :string
  end
end
