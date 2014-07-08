class AddColumnCostCenterIdToSectors < ActiveRecord::Migration
  def change
  	unless column_exists? :sectors, :cost_center_id
      add_column :sectors, :cost_center_id, :integer
 	end
  end
end
