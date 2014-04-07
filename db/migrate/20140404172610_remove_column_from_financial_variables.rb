class RemoveColumnFromFinancialVariables < ActiveRecord::Migration
  def change
    remove_column :financial_variables, :igv, :float
    remove_column :financial_variables, :retention, :float
    remove_column :financial_variables, :taxRate, :float
  end
end
