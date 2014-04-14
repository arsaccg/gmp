class CreateStockInputDetails < ActiveRecord::Migration
  def change
    create_table :stock_input_details do |t|
      t.references :stock_input, index: true
      t.references :purchase_order_detail, index: true
      t.decimal :amount
      t.string :status
      t.integer :user_inserts_id
      t.integer :user_updates_id

      t.timestamps
    end
  end
end
