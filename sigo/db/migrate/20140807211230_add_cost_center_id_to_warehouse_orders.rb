class AddCostCenterIdToWarehouseOrders < ActiveRecord::Migration
  def change
   	add_column :warehouse_orders,:cost_center_id, :int
  end
end
