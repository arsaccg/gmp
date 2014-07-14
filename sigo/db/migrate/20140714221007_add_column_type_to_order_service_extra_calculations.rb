class AddColumnTypeToOrderServiceExtraCalculations < ActiveRecord::Migration
  def change
    add_column :order_service_extra_calculations, :type, :string
  end
end
