class AddColumnResponsibleIdToStockInputs < ActiveRecord::Migration
  def change
    add_column :stock_inputs, :responsible_id, :integer
  end
end
