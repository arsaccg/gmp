class RemoveArticleUnitOfMeasurements < ActiveRecord::Migration
  def change
  	drop_table :article_unit_of_measurements
  end
end
