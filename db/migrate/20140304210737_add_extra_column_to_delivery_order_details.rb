class AddExtraColumnToDeliveryOrderDetails < ActiveRecord::Migration
  def change
    add_column :delivery_order_details, :amount, :integer
    add_column :delivery_order_details, :description, :text
  end
end
