class RemoveCodeAndNameFromDeliveryOrders < ActiveRecord::Migration
  def change
    remove_column :delivery_orders, :code, :string
    remove_column :delivery_orders, :name, :string
  end
end
