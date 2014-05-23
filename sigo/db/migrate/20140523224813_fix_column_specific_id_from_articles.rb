class FixColumnSpecificIdFromArticles < ActiveRecord::Migration
  def change
	rename_column :articles, :specific_id, :category_id
  	change_column :articles, :category_id, :string
  end
end
