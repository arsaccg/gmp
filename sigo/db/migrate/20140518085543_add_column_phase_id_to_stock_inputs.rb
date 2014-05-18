class AddColumnPhaseIdToStockInputs < ActiveRecord::Migration
  def change
    add_reference :stock_inputs, :phase, index: true
  end
end
