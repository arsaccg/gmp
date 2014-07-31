class AddCostCenterDetailsToEntities < ActiveRecord::Migration
  def change
  	add_column :entities, :cost_center_detail_id, :integer
  end
end
