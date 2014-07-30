class AddColumnProvisionIdToProvisionDirectPurchaseDetails < ActiveRecord::Migration
  def change
    add_column :provision_direct_purchase_details, :provision_id, :integer
  end
end
