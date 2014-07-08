class AddColumnCostCenterIdToPartOfEquipments < ActiveRecord::Migration
  def change
    add_column :part_of_equipments, :cost_center_id, :integer
  end
end
