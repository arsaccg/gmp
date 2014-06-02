class AddBlockToParts < ActiveRecord::Migration
  def change
  	add_column :part_of_equipments, :block, :integer
  	add_column :part_people, :block, :integer
  	add_column :part_works, :block, :integer
  end
end
