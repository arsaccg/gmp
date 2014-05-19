class AddCostCenterIdToWbsitem < ActiveRecord::Migration
  def change
    add_column :wbsitems, :cost_center_id, :integer
  end
end
