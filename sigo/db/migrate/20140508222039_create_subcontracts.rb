class CreateSubcontracts < ActiveRecord::Migration
  def change
    create_table :subcontracts do |t|
      t.integer :entity_id
      t.string :valorization
      t.string :terms_of_payment
      t.float :initial_amortization_number
      t.string :initial_amortization_percent
      t.string :guarantee_fund
      t.string :detraction
      t.float :contract_amount

      t.timestamps
    end
  end
end
