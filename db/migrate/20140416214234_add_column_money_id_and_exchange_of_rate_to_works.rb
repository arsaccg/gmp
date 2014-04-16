class AddColumnMoneyIdAndExchangeOfRateToWorks < ActiveRecord::Migration
  def change
    add_column :works, :money_id, :integer
    add_column :works, :exchange_of_rate, :string
  end
end
