class AddFuelToPartsDetails < ActiveRecord::Migration
  def change
  	add_column :part_of_equipment_details, :fuel, :float
  end
end
