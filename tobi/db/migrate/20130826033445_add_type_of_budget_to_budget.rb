class AddTypeOfBudgetToBudget < ActiveRecord::Migration
  def change
    add_column :budgets, :type_of_budget, :string
  end
end
