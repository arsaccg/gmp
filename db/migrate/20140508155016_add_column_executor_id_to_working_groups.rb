class AddColumnExecutorIdToWorkingGroups < ActiveRecord::Migration
  def change
    add_column :working_groups, :executor_id, :integer
  end
end
