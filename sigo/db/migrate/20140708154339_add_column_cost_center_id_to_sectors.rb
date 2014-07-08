class AddColumnCostCenterIdToSectors < ActiveRecord::Migration
  def change
    add_column :sectors, :cost_center_id, :integer
  end
end
