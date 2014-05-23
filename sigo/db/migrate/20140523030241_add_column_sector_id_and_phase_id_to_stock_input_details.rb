class AddColumnSectorIdAndPhaseIdToStockInputDetails < ActiveRecord::Migration
  def change
    add_reference :stock_input_details, :sector, index: true
    add_reference :stock_input_details, :phase, index: true
  end
end
