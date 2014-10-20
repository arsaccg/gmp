class AddColumToProvisionDetails < ActiveRecord::Migration
  def change
    add_column :provision_details, :amount_perception, :float
    add_column :provision_details, :amount_with_discount_before_igv, :string
    add_column :provision_details, :amount_after_igv_with_discount, :string
  end
end
