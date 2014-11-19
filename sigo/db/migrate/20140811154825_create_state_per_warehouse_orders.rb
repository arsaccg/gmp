class CreateStatePerWarehouseOrders < ActiveRecord::Migration
  def change
    create_table :state_per_warehouse_orders do |t|
      t.string :state
      t.integer :warehouse_order_id
      t.integer :user_id

      t.timestamps
    end
  end
end
