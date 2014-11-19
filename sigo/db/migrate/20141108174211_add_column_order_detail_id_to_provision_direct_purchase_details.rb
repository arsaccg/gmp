class AddColumnOrderDetailIdToProvisionDirectPurchaseDetails < ActiveRecord::Migration
  def change
    add_column :provision_direct_purchase_details, :order_detail_id, :integer
  end
end
