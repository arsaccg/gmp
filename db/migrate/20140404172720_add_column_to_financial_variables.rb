class AddColumnToFinancialVariables < ActiveRecord::Migration
  def change
    add_column :financial_variables, :name, :string
    add_column :financial_variables, :value, :float
  end
end
