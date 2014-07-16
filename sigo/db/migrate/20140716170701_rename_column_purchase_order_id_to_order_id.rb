class RenameColumnPurchaseOrderIdToOrderId < ActiveRecord::Migration
  def change
  	rename_column :provisions, :purchase_order_id, :order_id
  end
end
