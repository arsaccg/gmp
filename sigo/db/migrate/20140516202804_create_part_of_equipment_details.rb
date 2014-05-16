class CreatePartOfEquipmentDetails < ActiveRecord::Migration
  def change
    create_table :part_of_equipment_details do |t|
      t.integer :work_group_id
      t.integer :sub_sector_id
      t.integer :subphase_id
      t.float :effective_hours
      t.string :unit

      t.timestamps
    end
  end
end
