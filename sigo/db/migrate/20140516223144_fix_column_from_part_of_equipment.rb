class FixColumnFromPartOfEquipment < ActiveRecord::Migration
  def change
  	rename_column :part_of_equipments, :code, :code
  	change_column :part_of_equipments, :code, :string

  	rename_column :part_of_equipments, :hour_meter, :initial_km
  	change_column :part_of_equipments, :initial_km, :string

  	rename_column :part_of_equipments, :mileage, :final_km
  	change_column :part_of_equipments, :final_km, :string

  	rename_column :part_of_equipments, :sub_group_id, :subcategory_id
  	change_column :part_of_equipments, :subcategory_id, :integer

  	rename_column :part_of_equipments, :equipment, :equipment_id
  	change_column :part_of_equipments, :equipment_id, :integer
  end
end
