class RemoveCategoryIdColumnFromArticles < ActiveRecord::Migration
  def change
  	remove_column :articles, :category_id, :integer
  end
end
