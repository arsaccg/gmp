class AddLockToDeliveryOrderDetails < ActiveRecord::Migration
  def change
    add_column :delivery_order_details, :lock_version, :integer, :default => 0, :null => false
  end
end
