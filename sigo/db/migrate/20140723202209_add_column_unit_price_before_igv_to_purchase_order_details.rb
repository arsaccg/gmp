class AddColumnUnitPriceBeforeIgvToPurchaseOrderDetails < ActiveRecord::Migration
  def change
    add_column :purchase_order_details, :unit_price_before_igv, :float
  end
end
