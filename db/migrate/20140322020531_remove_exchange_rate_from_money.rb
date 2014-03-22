class RemoveExchangeRateFromMoney < ActiveRecord::Migration
  def change
  	remove_column :money, :exchange_rate, :decimal
  end
end
