class AddUtilityToBudget < ActiveRecord::Migration
  def change
    add_column :budgets, :utility, :float
  end
end
