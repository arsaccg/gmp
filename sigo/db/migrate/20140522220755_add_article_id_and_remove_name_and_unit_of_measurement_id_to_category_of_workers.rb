class AddArticleIdAndRemoveNameAndUnitOfMeasurementIdToCategoryOfWorkers < ActiveRecord::Migration
  def change
  	add_column :category_of_workers, :article_id, :integer
    remove_column :category_of_workers, :name
    remove_column :category_of_workers, :unit_of_measurement_id
  end
end
