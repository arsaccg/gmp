class RenameColumnSubphaseIdFromPartOfEquipmentDetails < ActiveRecord::Migration
  def change
  	rename_column :part_of_equipment_details, :subphase_id, :phase_id
  end
end
