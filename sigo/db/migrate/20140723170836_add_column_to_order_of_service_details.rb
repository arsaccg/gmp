class AddColumnToOrderOfServiceDetails < ActiveRecord::Migration
  def change
    add_column :order_of_service_details, :unit_price_before_igv, :float
  end
end
