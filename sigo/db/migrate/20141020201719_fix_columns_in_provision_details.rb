class FixColumnsInProvisionDetails < ActiveRecord::Migration
  def change
  	rename_column :provision_details, :amount_with_discount_before_igv, :discount_before_igv
  	rename_column :provision_details, :amount_after_igv_with_discount, :discount_after_igv
  end
end
