class AddColumnUnitCostToStockInputDetails < ActiveRecord::Migration
  def change
    add_column :stock_input_details, :unit_cost, :decimal, :precision => 15, :scale => 5
  end
end
