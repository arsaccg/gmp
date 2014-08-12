class FixColumnGeneralExpenses < ActiveRecord::Migration
  def change
  	change_column :general_expense_details, :cost, :string
  end
end
