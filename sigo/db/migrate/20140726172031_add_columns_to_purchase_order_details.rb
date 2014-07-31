class AddColumnsToPurchaseOrderDetails < ActiveRecord::Migration
  def change
  	add_column :purchase_order_details, :quantity_igv, :float
  	add_column :purchase_order_details, :discount_after, :float
  	add_column :purchase_order_details, :discount_before, :float
  end
end
