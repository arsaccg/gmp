class RenameColumnWorkGroupIdFromPartOfEquipmentDetails < ActiveRecord::Migration
  def change
  	rename_column :part_of_equipment_details, :work_group_id, :working_group_id
  end
end
