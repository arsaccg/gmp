class AddMoreColumnsForSummaryToOrderOfServiceDetails < ActiveRecord::Migration
  def change
    add_column :order_of_service_details, :discount_before, :float
    add_column :order_of_service_details, :discount_after, :float
    add_column :order_of_service_details, :quantity_igv, :float
  end
end
