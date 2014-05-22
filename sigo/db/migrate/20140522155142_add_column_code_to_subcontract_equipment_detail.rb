class AddColumnCodeToSubcontractEquipmentDetail < ActiveRecord::Migration
  def change
    add_column :subcontract_equipment_details, :code, :string
  end
end
