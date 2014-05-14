class CreateSubcontractEquipments < ActiveRecord::Migration
  def change
    create_table :subcontract_equipments do |t|
      t.integer :entity_id
      t.string :valorization
      t.string :terms_of_payment
      t.float :initial_amortization_number
      t.string :initial_amortization_percent
      t.string :guarantee_fund
      t.string :detraction
      t.float :contract_amount
      t.string :type

      t.timestamps
    end
  end
end
