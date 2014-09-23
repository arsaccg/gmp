class AddColumnsLock < ActiveRecord::Migration
  def change
  	add_column :part_of_equipments, :lock_version, :integer, :default => 0, :null => false
  	add_column :part_of_equipment_details, :lock_version, :integer, :default => 0, :null => false
  	add_column :part_people, :lock_version, :integer, :default => 0, :null => false
  	add_column :part_person_details, :lock_version, :integer, :default => 0, :null => false
  	add_column :part_workers, :lock_version, :integer, :default => 0, :null => false
  	add_column :part_worker_details, :lock_version, :integer, :default => 0, :null => false
  	add_column :part_works, :lock_version, :integer, :default => 0, :null => false
  	add_column :part_work_details, :lock_version, :integer, :default => 0, :null => false
  end
end
