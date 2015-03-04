class CreateBondLetterDetails < ActiveRecord::Migration
  def change
    create_table :bond_letter_details do |t|
      t.string :code
      t.date :issu_date
      t.datetime :expiration_date
      t.float :amount
      t.float :issuance_cost
      t.float :retention
      t.float :rate
      t.integer :bond_letter_id

      t.timestamps
    end
  end
end
