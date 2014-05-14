class CreateOrderOfServiceDetails < ActiveRecord::Migration
  def change
    create_table :order_of_service_details do |t|
      t.integer :article_id
      t.integer :sector_id
      t.integer :phase_id
      t.integer :unit_of_measurement_id
      t.integer :amount
      t.float :unit_price
      t.boolean :igv
      t.integer :unit_price_igv
      t.text :description

      t.timestamps
    end
  end
end
