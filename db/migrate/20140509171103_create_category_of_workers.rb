class CreateCategoryOfWorkers < ActiveRecord::Migration
  def change
    create_table :category_of_workers do |t|
      t.string :name
      t.float :normal_price
      t.float :he_60_price
      t.float :he_100_price
      t.integer :unit_of_measurement_id

      t.timestamps
    end
  end
end
