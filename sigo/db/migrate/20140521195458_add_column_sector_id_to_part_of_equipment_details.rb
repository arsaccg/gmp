class AddColumnSectorIdToPartOfEquipmentDetails < ActiveRecord::Migration
  def change
    add_column :part_of_equipment_details, :sector_id, :integer
  end
end
