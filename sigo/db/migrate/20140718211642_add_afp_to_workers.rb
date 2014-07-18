class AddAfpToWorkers < ActiveRecord::Migration
  def change
  	add_column :workers,:afp_id, :integer
  end
end
