class RemoveTableGenericForWeeksAndArticles < ActiveRecord::Migration
  def change
  	drop_table :weeks_per_cost_centers if table_exists? :weeks_per_cost_centers
  	drop_table :articles_from_cost_centers if table_exists? :articles_from_cost_centers
  end
end
