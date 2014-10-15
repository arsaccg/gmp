class AddColumnCostCenterIdToPaymentOrders < ActiveRecord::Migration
  def change
    add_column :payment_orders, :cost_center_id, :integer
  end
end
