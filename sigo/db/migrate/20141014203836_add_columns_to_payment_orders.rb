class AddColumnsToPaymentOrders < ActiveRecord::Migration
  def change
    add_column :payment_orders, :percent_detraction, :string
    add_column :payment_orders, :detraction, :string
  end
end
