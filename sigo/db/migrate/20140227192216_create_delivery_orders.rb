class CreateDeliveryOrders < ActiveRecord::Migration
  def change
    create_table :delivery_orders do |t|
      t.string :state

      t.timestamps
    end
  end
end
