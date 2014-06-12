class Addblock2Topartpeople < ActiveRecord::Migration
  def change
  	add_column :part_people, :block2, :integer
  end
end
