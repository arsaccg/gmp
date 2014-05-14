class AddColumnDeliveryOrderIdToDeliveryOrderDetails < ActiveRecord::Migration
  def change
    add_column :delivery_order_details, :delivery_order_id, :integer
  end
end
