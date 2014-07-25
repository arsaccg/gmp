class RemoveAfpIdfromWorkers < ActiveRecord::Migration
  def change
  	remove_column :workers, :afp_id
  	remove_column :workers, :afptype
  	remove_column :workers, :afpnumber
  end
end
