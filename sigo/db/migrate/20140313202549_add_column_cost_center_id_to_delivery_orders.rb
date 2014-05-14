class AddColumnCostCenterIdToDeliveryOrders < ActiveRecord::Migration
  def change
    add_column :delivery_orders, :cost_center_id, :integer
  end
end
