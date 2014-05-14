class AddColumnYearToStockInputs < ActiveRecord::Migration
  def change
    add_column :stock_inputs, :year, :integer, index: true
  end
end
