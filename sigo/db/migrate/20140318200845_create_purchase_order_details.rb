class CreatePurchaseOrderDetails < ActiveRecord::Migration
  def change
    create_table :purchase_order_details do |t|
      t.integer :delivery_order_detail_id
      t.float :unit_price
      t.boolean :igv
      t.float :unit_price_igv
      t.text :description

      t.timestamps
    end
  end
end
