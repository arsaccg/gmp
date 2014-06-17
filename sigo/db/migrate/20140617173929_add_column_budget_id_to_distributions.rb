class AddColumnBudgetIdToDistributions < ActiveRecord::Migration
  def change
    add_column :distributions, :budget_id, :integer
  end
end
