class AddColumnToSubcontractEquipments < ActiveRecord::Migration
  def change
     add_column :subcontract_equipments, :contract_description, :string
  end
end
