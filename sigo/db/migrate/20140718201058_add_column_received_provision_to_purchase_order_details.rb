class AddColumnReceivedProvisionToPurchaseOrderDetails < ActiveRecord::Migration
  def change
    add_column :purchase_order_details, :received_provision, :bool
  end
end
