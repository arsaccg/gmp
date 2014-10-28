class AddCodeToDeliveryOrders < ActiveRecord::Migration
  def change
    add_column :delivery_orders, :code, :string
  end
end
