class CreateWarehouseOrderDetails < ActiveRecord::Migration
  def change
    create_table :warehouse_order_details do |t|
      t.integer :article_id
      t.integer :quantity
      t.integer :sector_id
      t.integer :phase_id
      t.integer :warehouse_order_id

      t.timestamps
    end
  end
end
