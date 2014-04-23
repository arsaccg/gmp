class AddMoreColumntoWorks < ActiveRecord::Migration
  def change
   add_column :works, :amount_contract_of_inquiry, :string
   add_column :works, :amount_settlement_of_inquiry, :string
   add_column :works, :amount_contract_of_is, :string
   add_column :works, :amount_settlement_of_is, :string
  end
end
