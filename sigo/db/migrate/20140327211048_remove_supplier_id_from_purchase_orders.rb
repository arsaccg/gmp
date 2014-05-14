class RemoveSupplierIdFromPurchaseOrders < ActiveRecord::Migration
  def change
    remove_column :purchase_orders, :supplier_id, :integer
  end
end
