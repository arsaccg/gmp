class FixColumnEntityFromPartOfEquipment < ActiveRecord::Migration
  def change
  	rename_column :part_of_equipments, :entity_id, :subcontract_of_equipment_id
  	change_column :part_of_equipments, :subcontract_of_equipment_id, :integer
  end
end
