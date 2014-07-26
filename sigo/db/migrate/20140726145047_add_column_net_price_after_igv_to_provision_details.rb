class AddColumnNetPriceAfterIgvToProvisionDetails < ActiveRecord::Migration
  def change
    add_column :provision_details, :net_price_after_igv, :float
  end
end
