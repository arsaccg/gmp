class AddColumnCodeToGeneralExpenses < ActiveRecord::Migration
  def change
    add_column :general_expenses, :code_phase, :string
  end
end