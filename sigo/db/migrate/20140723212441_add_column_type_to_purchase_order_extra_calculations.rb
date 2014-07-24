class AddColumnTypeToPurchaseOrderExtraCalculations < ActiveRecord::Migration
  def change
    add_column :purchase_order_extra_calculations, :type, :string
  end
end
