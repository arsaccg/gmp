class AddBudgetIdToValorizationCache < ActiveRecord::Migration
  def change
    add_column :valorization_caches, :budget_id, :integer
  end
end
