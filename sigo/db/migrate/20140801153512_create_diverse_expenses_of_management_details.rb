class CreateDiverseExpensesOfManagementDetails < ActiveRecord::Migration
  def change
    create_table :diverse_expenses_of_management_details do |t|
      t.integer :diverse_expenses_of_management_id
      t.string :code
      t.float :amount
      t.date :delivered_date
      t.integer :entity_id
      t.string :bill_concept
      t.string :bill
      t.date :bill_date
      t.string :bill_amount
      t.string :bill_detraction
      t.string :bill_to_account
      t.string :igv_commission
      t.string :net_return
      t.string :balance

      t.timestamps
    end
  end
end
