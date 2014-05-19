class AddProjectIdToBudgets < ActiveRecord::Migration
  def change
  	add_column :budgets, :project_id, :integer
  	add_column :budgets, :level, :integer
  	add_column :budgets, :subbudget_code, :string
  	add_column :budgets, :deleted, :integer
  end
end
