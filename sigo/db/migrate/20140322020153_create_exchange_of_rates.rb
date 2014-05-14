class CreateExchangeOfRates < ActiveRecord::Migration
  def change
    create_table :exchange_of_rates do |t|
      t.datetime :day
      t.references :money, index: true
      t.decimal :value, precision: 15, scale: 5
      
      t.timestamps
    end
  end
end
