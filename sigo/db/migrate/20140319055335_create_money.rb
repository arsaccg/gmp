class CreateMoney < ActiveRecord::Migration
  def change
    create_table :money do |t|
      t.string :name
      t.string :symbol
      t.decimal :exchange_rate
    end
  end
end
