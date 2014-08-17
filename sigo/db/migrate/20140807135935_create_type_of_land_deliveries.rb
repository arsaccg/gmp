class CreateTypeOfLandDeliveries < ActiveRecord::Migration
  def change
    create_table :type_of_land_deliveries do |t|
      t.string :name
      t.string :preffix
      t.integer :cost_center_id

      t.timestamps
    end
  end
end
