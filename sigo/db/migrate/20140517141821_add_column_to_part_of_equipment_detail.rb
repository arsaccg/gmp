class AddColumnToPartOfEquipmentDetail < ActiveRecord::Migration
  def change
    add_column :part_of_equipment_details, :part_of_equipment_id, :integer
  end
end
