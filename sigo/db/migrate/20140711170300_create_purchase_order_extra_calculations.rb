class CreatePurchaseOrderExtraCalculations < ActiveRecord::Migration
  def change
    create_table :purchase_order_extra_calculations do |t|
      t.integer :purchase_order_detail_id
      t.integer :extra_calculation_id
      t.float :value
      t.string :apply
      t.string :operation

      t.timestamps
    end
  end
end
