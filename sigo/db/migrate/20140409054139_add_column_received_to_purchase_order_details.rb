class AddColumnReceivedToPurchaseOrderDetails < ActiveRecord::Migration
  def change
    add_column :purchase_order_details, :received, :boolean
  end
end
