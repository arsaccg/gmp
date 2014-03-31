class AddUnitOfMeasurementIdToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :unit_of_measurement_id, :integer
  end
end
