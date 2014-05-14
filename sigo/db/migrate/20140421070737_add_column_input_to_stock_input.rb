class AddColumnInputToStockInput < ActiveRecord::Migration
  def change
    add_column :stock_inputs, :input, :integer
  end
end
