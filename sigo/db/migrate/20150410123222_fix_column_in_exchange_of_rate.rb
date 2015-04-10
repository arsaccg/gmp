class FixColumnInExchangeOfRate < ActiveRecord::Migration
  def change
  	change_column :exchange_of_rates, :day, :date
  end
end
