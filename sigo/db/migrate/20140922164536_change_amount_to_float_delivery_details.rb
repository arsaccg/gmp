class ChangeAmountToFloatDeliveryDetails < ActiveRecord::Migration
  def change
  	change_column :delivery_order_details, :amount, :float
  end
end
