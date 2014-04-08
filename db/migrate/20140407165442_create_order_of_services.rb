class CreateOrderOfServices < ActiveRecord::Migration
  def change
    create_table :order_of_services do |t|
      t.string :state
      t.datetime :date_of_issue
      t.text :description
      t.integer :method_of_payment_id
      t.integer :entity_id
      t.integer :user_id
      t.integer :cost_center_id

      t.timestamps
    end
  end
end
