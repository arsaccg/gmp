class AddGeneralExpensesToBudget < ActiveRecord::Migration
  def change
    add_column :budgets, :general_expenses, :float
  end
end
