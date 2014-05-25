class CreateFinancialVariables < ActiveRecord::Migration
  def change
    if !table_exists? :financial_variables
      create_table :financial_variables do |t|
        t.string :name
        t.float :value

        t.timestamps
      end
    end
  end
end