class CreateWarehouses < ActiveRecord::Migration
  def change
    create_table :warehouses do |t|
      t.string :name
      t.string :location
      t.string :status
      t.references :cost_center, index: true
      t.integer :user_inserts_id
      t.integer :user_updates_id

      t.timestamps
    end
  end
end
