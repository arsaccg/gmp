class ChangeExchangeRateColumnAddScale < ActiveRecord::Migration
  def change
  	change_column :money, :exchange_rate, :decimal, :precision => 15, :scale => 5, null: false
  end
end
