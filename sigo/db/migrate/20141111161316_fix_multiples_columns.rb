class FixMultiplesColumns < ActiveRecord::Migration
  def change
  	change_column :purchase_order_details, :unit_price, :string
  	change_column :purchase_order_details, :unit_price_before_igv, :string
  	change_column :purchase_order_details, :discount_before, :string
  	change_column :purchase_order_details, :quantity_igv, :string
  	change_column :purchase_order_details, :discount_after, :string
  	change_column :purchase_order_details, :unit_price_igv, :string
  	
  	change_column :order_of_service_details, :unit_price, :string
  	change_column :order_of_service_details, :unit_price_before_igv, :string
  	change_column :order_of_service_details, :discount_before, :string
  	change_column :order_of_service_details, :quantity_igv, :string
  	change_column :order_of_service_details, :discount_after, :string
  	change_column :order_of_service_details, :unit_price_igv, :string
  end
end
