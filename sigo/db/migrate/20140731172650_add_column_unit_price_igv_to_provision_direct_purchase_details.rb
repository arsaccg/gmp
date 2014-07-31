class AddColumnUnitPriceIgvToProvisionDirectPurchaseDetails < ActiveRecord::Migration
  def change
    add_column :provision_direct_purchase_details, :unit_price_igv, :float
  end
end
