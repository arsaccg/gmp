class AddColumnOrderToProvisionDirectPurchaseDetails < ActiveRecord::Migration
  def change
    add_column :provision_direct_purchase_details, :order_id, :integer
  end
end
