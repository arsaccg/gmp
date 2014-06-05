class AddColumnEntityIdAndDestroyExtraColumnsToWorkers < ActiveRecord::Migration
  def change
  	add_column :workers, :entity_id, :integer
  	remove_column :workers, :first_name
  	remove_column :workers, :second_name 
  	remove_column :workers, :paternal_surname 
  	remove_column :workers, :maternal_surname 
  	remove_column :workers, :email 
  	remove_column :workers, :address 
  end
end
