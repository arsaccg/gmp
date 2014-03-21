class AddColumnPurchaseOrderIdToPurchaseOrderDetails < ActiveRecord::Migration
  def change
    add_column :purchase_order_details, :purchase_order_id, :integer
  end
end
