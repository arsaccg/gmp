class CreateOrderServiceExtraCalculations < ActiveRecord::Migration
  def change
    create_table :order_service_extra_calculations do |t|
      t.integer :order_of_service_detail_id
      t.integer :extra_calculation_id
      t.float :value
      t.string :apply
      t.string :operation

      t.timestamps
    end
  end
end
