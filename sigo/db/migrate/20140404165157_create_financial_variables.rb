class CreateFinancialVariables < ActiveRecord::Migration
  def change
    create_table :financial_variables do |t|
	  t.string :name
	  t.float :value

	  t.timestamps
	end
  end
end