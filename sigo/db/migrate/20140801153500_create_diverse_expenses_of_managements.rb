class CreateDiverseExpensesOfManagements < ActiveRecord::Migration
  def change
    create_table :diverse_expenses_of_managements do |t|
      t.string :name
      t.string :amount
      t.string :expenses
      t.string :total_delivered
      t.integer :cost_center_id
      t.float :percentage

      t.timestamps
    end
  end
end
