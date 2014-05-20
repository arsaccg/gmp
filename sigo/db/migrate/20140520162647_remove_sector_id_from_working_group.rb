class RemoveSectorIdFromWorkingGroup < ActiveRecord::Migration
  def change
  	remove_column :working_groups, :sector_id
  end
end
