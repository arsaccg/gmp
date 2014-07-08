class AddColumnCostCenterIdToWorkingGroups < ActiveRecord::Migration
  def change
    add_column :working_groups, :cost_center_id, :integer
  end
end
