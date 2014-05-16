class AddColumnToSubcontractEquipmentDetails < ActiveRecord::Migration
  def change
    add_column :subcontract_equipment_details, :subcontract_equipment_id, :integer
  end
end
