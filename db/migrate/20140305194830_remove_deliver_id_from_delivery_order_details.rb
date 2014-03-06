class RemoveDeliverIdFromDeliveryOrderDetails < ActiveRecord::Migration
  def change
    remove_column :delivery_order_details, :deliver_order_id, :integer
  end
end
