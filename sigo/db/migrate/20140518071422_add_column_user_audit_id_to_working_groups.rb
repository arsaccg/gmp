raiclass AddColumnUserAuditIdToWorkingGroups < ActiveRecord::Migration
  def change
    add_column :working_groups, :user_inserts_id, :integer
    add_column :working_groups, :user_updates_id, :integer
  end
end
