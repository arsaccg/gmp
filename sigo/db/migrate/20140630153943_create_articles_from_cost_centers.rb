class CreateArticlesFromCostCenters < ActiveRecord::Migration
  def change
    create_table :articles_from_cost_centers do |t|
      t.integer :article_id
      t.string :code
      t.integer :type_of_article_id
      t.integer :category_id
      t.string :name
      t.text :description
      t.integer :unit_of_measurement_id
      t.integer :cost_center_id
      t.integer :input_by_budget_and_items_id
      t.integer :budget_id

      t.timestamps
    end
  end
end
