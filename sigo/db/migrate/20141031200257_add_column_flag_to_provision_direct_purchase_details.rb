class AddColumnFlagToProvisionDirectPurchaseDetails < ActiveRecord::Migration
  def change
    add_column :provision_direct_purchase_details, :flag, :integer
  end
end
