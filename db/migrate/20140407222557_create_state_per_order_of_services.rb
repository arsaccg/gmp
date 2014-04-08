class CreateStatePerOrderOfServices < ActiveRecord::Migration
  def change
    create_table :state_per_order_of_services do |t|
      t.string :state
      t.integer :order_of_service_id
      t.integer :user_id

      t.timestamps
    end
  end
end
