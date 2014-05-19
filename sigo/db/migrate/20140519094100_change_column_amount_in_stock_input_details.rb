class ChangeColumnAmountInStockInputDetails < ActiveRecord::Migration
  def change
  	change_column :stock_input_details, :amount, :decimal, :precision => 15, :scale => 5
  end
end
