class RemoveColumnUnitOfMeasureIdOfArticles < ActiveRecord::Migration
  def change
  	remove_column :articles, :unit_of_measure_id 
  end
end
