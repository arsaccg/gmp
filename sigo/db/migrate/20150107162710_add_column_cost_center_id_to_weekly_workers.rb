class AddColumnCostCenterIdToWeeklyWorkers < ActiveRecord::Migration
  def change
    add_column :weekly_workers, :cost_center_id, :integer
  end
end
