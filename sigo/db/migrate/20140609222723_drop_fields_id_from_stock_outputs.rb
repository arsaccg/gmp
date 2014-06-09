class DropFieldsIdFromStockOutputs < ActiveRecord::Migration
  def change
  	remove_column :stock_inputs, :supplier_id
  	remove_column :stock_inputs, :series
  end
end
