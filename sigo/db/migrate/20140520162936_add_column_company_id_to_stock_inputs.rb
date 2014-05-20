class AddColumnCompanyIdToStockInputs < ActiveRecord::Migration
  def change
    add_reference :stock_inputs, :company, index: true
  end
end
