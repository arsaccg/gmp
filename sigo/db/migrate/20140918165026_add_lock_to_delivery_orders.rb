class AddLockToDeliveryOrders < ActiveRecord::Migration
  def change
     add_column :delivery_orders, :lock_version, :integer, :default => 0, :null => false
  end
end
