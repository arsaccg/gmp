class CreateMethodOfPayments < ActiveRecord::Migration
  def change
    create_table :method_of_payments do |t|
      t.string :name
      t.string :symbol
    end
  end
end
