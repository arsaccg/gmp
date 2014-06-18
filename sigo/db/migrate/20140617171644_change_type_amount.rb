class ChangeTypeAmount < ActiveRecord::Migration
  def change
  	change_column :stock_input_details, :amount, :float
  	change_column :stock_input_details, :unit_cost, :float
  end
end
