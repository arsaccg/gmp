class AddColumnTypeOfOrderToProvisionDirectPurchaseDetails < ActiveRecord::Migration
  def change
    add_column :provision_direct_purchase_details, :type_order, :string
  end
end
