class AddAmountToCharges < ActiveRecord::Migration
  def change
  	add_column :charges, :amount, :float
  	add_column :charges, :charge_date, :date
  	add_column :charges, :payment_amount, :float
  	add_column :charges, :financial_agent_client, :string
  	add_column :charges, :financial_agent_destiny, :string
  	add_column :charges, :invoice_id, :integer
  end
end
