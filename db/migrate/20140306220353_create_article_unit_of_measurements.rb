class CreateArticleUnitOfMeasurements < ActiveRecord::Migration
  def change
    create_table :article_unit_of_measurements do |t|
      t.integer :article_id
      t.integer :unit_of_measurement_id

      t.timestamps
    end
  end
end
