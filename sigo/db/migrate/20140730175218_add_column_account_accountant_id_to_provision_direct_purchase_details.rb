class AddColumnAccountAccountantIdToProvisionDirectPurchaseDetails < ActiveRecord::Migration
  def change
    add_column :provision_direct_purchase_details, :account_accountant_id, :integer
  end
end
