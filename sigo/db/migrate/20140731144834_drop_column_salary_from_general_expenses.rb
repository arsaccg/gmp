class DropColumnSalaryFromGeneralExpenses < ActiveRecord::Migration
  def change
  	remove_column :general_expense_details, :salary
  end
end
