class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.integer :invoice_id
      t.float :amount
      t.date :charge_date
      t.float :payment_amount
      t.string :financial_agent_client
      t.string :financial_agent_destiny

      t.timestamps
    end
  end
end
