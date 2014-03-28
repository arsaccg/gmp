class AddColumnEntityIdToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :entity_id, :integer
  end
end
