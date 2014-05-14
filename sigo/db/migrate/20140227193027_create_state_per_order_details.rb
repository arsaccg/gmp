class CreateStatePerOrderDetails < ActiveRecord::Migration
  def change
    create_table :state_per_order_details do |t|
      t.integer :delivery_order_id
      t.string :state

      t.timestamps
    end
  end
end
