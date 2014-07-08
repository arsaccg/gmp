class AddColumnCostCenterIdToPartOfEquipments < ActiveRecord::Migration
  def change
  	unless column_exists? :part_of_equipments, :cost_center_id
      add_column :part_of_equipments, :cost_center_id, :integer
  	end
  end
end
