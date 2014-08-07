class CreateWarehouseOrders < ActiveRecord::Migration
  def change
    create_table :warehouse_orders do |t|
      t.string :code
      t.integer :working_group_id
      t.date :date

      t.timestamps
    end
  end
end
