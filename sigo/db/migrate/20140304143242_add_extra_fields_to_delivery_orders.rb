class AddExtraFieldsToDeliveryOrders < ActiveRecord::Migration
  def change
    add_column :delivery_orders, :code, :string
    add_column :delivery_orders, :name, :string
    add_column :delivery_orders, :user_id, :integer
    add_column :delivery_orders, :date_of_issue, :date
    add_column :delivery_orders, :scheduled, :date
    add_column :delivery_orders, :description, :text
  end
end
