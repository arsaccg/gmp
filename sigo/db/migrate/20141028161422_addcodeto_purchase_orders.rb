class AddcodetoPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :code, :string
  end
end
