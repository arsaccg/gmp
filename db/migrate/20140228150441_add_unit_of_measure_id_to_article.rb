class AddUnitOfMeasureIdToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :unit_of_measure_id, :integer
  end
end
