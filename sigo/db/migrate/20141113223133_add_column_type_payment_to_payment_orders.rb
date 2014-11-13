class AddColumnTypePaymentToPaymentOrders < ActiveRecord::Migration
  def change
    add_column :payment_orders, :type_payment, :string
  end
end
