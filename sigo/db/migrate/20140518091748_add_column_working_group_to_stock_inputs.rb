class AddColumnWorkingGroupToStockInputs < ActiveRecord::Migration
  def change
    add_reference :stock_inputs, :working_group, index: true
  end
end
