class RenameColumnSubcontractOfEquipmentsIdFromPartOfEquipments < ActiveRecord::Migration
  def change
    rename_column :part_of_equipments, :subcontract_of_equipment_id, :subcontract_equipment_id
  end
end
