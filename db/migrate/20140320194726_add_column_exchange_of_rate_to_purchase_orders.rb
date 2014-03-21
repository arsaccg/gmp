class AddColumnExchangeOfRateToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :exchange_of_rate, :float
  end
end
