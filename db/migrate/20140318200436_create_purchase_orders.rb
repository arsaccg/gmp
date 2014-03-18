class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.string :state
      t.date :date_of_issue
      t.date :expiration_date
      t.date :delivery_date
      t.boolean :retention
      t.integer :money_id
      t.integer :method_of_payment_id
      t.integer :supplier_id
      t.integer :user_id
      t.integer :cost_center_id
      t.text :description

      t.timestamps
    end
  end
end
