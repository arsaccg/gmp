class DropOnpafpFromWorkers < ActiveRecord::Migration
  def change
  	remove_column :workers, :onpafp
  end
end
