class AddColumnAmountToPurchaseOrderDetails < ActiveRecord::Migration
  def change
    add_column :purchase_order_details, :amount, :integer
  end
end
