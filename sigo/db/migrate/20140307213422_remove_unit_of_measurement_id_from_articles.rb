class RemoveUnitOfMeasurementIdFromArticles < ActiveRecord::Migration
  def change
    remove_column :articles, :unit_of_measurement_id, :integer
  end
end
