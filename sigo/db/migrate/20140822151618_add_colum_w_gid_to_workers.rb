class AddColumWGidToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :position_wg_id, :integer
  end
end
