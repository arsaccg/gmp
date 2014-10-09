class AddColumnSubcontractEquipmentIdToValuationOfEquipments < ActiveRecord::Migration
  def change
    add_column :valuation_of_equipments, :subcontract_equipment_id, :integer
  end
end
