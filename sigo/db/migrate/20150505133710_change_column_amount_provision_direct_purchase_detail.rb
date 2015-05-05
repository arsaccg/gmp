class ChangeColumnAmountProvisionDirectPurchaseDetail < ActiveRecord::Migration
  def change
  	change_column :provision_direct_purchase_details, :amount, :float
  end
end
