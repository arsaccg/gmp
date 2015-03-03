class ChangeTypeColumnIntegerToFloatForOrderOfServiceDetails < ActiveRecord::Migration
  def change
	change_column :order_of_service_details, :amount, :float
  end
end
