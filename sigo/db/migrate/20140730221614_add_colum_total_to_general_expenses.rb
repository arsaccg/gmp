class AddColumTotalToGeneralExpenses < ActiveRecord::Migration
  def change
    add_column :general_expenses, :total, :string
  end
end
