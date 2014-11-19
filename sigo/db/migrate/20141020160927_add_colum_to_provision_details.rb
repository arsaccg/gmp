class AddColumToProvisionDetails < ActiveRecord::Migration
  def change
    add_column :provision_details, :amount_perception, :float, :default 0.0
    add_column :provision_details, :amount_with_discount_before_igv, :string, :default 0.0
    add_column :provision_details, :amount_after_igv_with_discount, :string,:default 0.0
  end
end
