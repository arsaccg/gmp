class CreateDeliveryOrderDetails < ActiveRecord::Migration
  def change
    create_table :delivery_order_details do |t|
      t.integer :deliver_order_id
      t.integer :phase_id
      t.integer :sector_id
      t.integer :person_id
      t.integer :article_id

      t.timestamps
    end
  end
end
