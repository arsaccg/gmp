class AddColumnEquipmentToStockInputDetails < ActiveRecord::Migration
  def change
    add_reference :stock_input_details, :article, index: true
    add_column :stock_input_details, :equipment_id, :integer
  end
end
