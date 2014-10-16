class AddMoreColumnsToPaymentOrders < ActiveRecord::Migration
  def change
    add_column :payment_orders, :perception, :string
    add_column :payment_orders, :total, :string
    add_column :payment_orders, :sub_total, :string
    add_column :payment_orders, :guarantee_fund_n1, :string
    add_column :payment_orders, :other_discounts, :string
  end
end
