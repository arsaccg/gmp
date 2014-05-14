class AddColumnExchangeOfRateToOrderOfServices < ActiveRecord::Migration
  def change
    add_column :order_of_services, :exchange_of_rate, :float
  end
end
