class ChangeInttoFloatPartOfEquipments < ActiveRecord::Migration
  def change
  	change_column :part_person_details, :normal_hours, :float
  	change_column :part_person_details, :he_60, :float
  	change_column :part_person_details, :he_100, :float
  	change_column :part_person_details, :total_hours, :float
  end
end
