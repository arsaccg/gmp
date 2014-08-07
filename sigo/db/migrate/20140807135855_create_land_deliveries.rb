class CreateLandDeliveries < ActiveRecord::Migration
  def change
    create_table :land_deliveries do |t|
      t.string :name
      t.string :description
      t.integer :cost_center_id
      t.integer :type_of_land_delivery_id
      t.string :document
      t.string :document_file_name
      t.string :document_content_type
      t.integer :document_file_size
      t.datetime :document_updated_at

      t.timestamps
    end
  end
end
