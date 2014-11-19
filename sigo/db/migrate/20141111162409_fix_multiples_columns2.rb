class FixMultiplesColumns2 < ActiveRecord::Migration
  def change
  	change_column :provision_direct_purchase_details, :price, :string
  	change_column :provision_direct_purchase_details, :unit_price_before_igv, :string
  	change_column :provision_direct_purchase_details, :discount_before, :string
  	change_column :provision_direct_purchase_details, :quantity_igv, :string
  	change_column :provision_direct_purchase_details, :discount_after, :string
  	change_column :provision_direct_purchase_details, :unit_price_igv, :string
  end
end
