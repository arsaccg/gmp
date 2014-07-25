class ChangeIntegerFormatInOrderOfServiceDetails < ActiveRecord::Migration
  def change
    change_column :order_of_service_details, :unit_price_igv, :float
  end
end
