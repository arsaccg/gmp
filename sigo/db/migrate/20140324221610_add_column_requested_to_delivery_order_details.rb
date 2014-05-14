class AddColumnRequestedToDeliveryOrderDetails < ActiveRecord::Migration
  def change
    add_column :delivery_order_details, :requested, :boolean
  end
end
