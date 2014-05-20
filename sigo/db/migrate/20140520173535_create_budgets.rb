class CreateBudgets < ActiveRecord::Migration
  def change
    create_table :budgets do |t|
      t.string :cod_budget
      t.string :description
      t.integer :term
      t.integer :cost_center_id
      t.integer :level
      t.string :subbudget_code
      t.integer :deleted
      t.string :type_of_budget
      t.float :utility
      t.float :general_expenses

      t.timestamps
    end
  end
end
