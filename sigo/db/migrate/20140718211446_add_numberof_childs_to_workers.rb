class AddNumberofChildsToWorkers < ActiveRecord::Migration
  def change
  	add_column :workers,:numberofchilds, :integer
  end
end
