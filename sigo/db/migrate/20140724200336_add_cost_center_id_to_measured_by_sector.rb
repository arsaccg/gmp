class AddCostCenterIdToMeasuredBySector < ActiveRecord::Migration
  def change
    add_column :measured_by_sectors, :cost_center_id, :integer
  end
end
