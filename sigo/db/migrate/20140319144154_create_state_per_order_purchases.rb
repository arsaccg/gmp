class CreateStatePerOrderPurchases < ActiveRecord::Migration
  def change
    create_table :state_per_order_purchases do |t|
      t.string :state
      t.integer :purchase_order_id
      t.integer :user_id

      t.timestamps
    end
  end
end
