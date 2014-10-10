class AddStateToSubcontractEquipmentDetails < ActiveRecord::Migration
  def change
    add_column :subcontract_equipment_details, :state, :string
  end
end
