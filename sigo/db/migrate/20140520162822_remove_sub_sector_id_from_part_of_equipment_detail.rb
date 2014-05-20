class RemoveSubSectorIdFromPartOfEquipmentDetail < ActiveRecord::Migration
  def change
  	remove_column :part_of_equipment_details, :sub_sector_id
  end
end
