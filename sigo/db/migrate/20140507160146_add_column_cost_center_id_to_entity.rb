class AddColumnCostCenterIdToEntity < ActiveRecord::Migration
  def change
    add_column :entities, :cost_center_id, :integer
  end
end
