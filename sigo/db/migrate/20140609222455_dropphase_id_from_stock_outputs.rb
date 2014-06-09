class DropphaseIdFromStockOutputs < ActiveRecord::Migration
  def change
  	remove_column :stock_inputs, :phase_id
  end
end
