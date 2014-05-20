class AddColumnCostCenterIdToStockInputs < ActiveRecord::Migration
  def change
    add_reference :stock_inputs, :cost_center, index: true
  end
end
