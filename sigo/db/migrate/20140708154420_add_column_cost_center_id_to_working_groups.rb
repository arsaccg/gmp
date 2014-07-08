class AddColumnCostCenterIdToWorkingGroups < ActiveRecord::Migration
  def change
  	unless column_exists? :working_groups, :cost_center_id
      add_column :working_groups, :cost_center_id, :integer
  	end
  end
end
